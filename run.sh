#!/usr/bin/env bash
#
# run.sh — one script to set up, test, and run Zing It.
#
# Usage:
#   ./run.sh              Run locally with Django's dev server (default)
#   ./run.sh local        Same as above
#   ./run.sh prod         Run locally with Gunicorn (DEBUG off, like production)
#   ./run.sh test         Run the test suite
#   ./run.sh docker       Build the Docker image and run the container
#   ./run.sh docker-stop  Stop and remove the running container
#
# Environment variables:
#   PORT   Port to listen on (default: 8000)
#
set -euo pipefail

cd "$(dirname "$0")"

PORT="${PORT:-8000}"
VENV_DIR=".venv"
IMAGE_NAME="zing-it"
CONTAINER_NAME="zing-it"

green()  { printf "\033[1;32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[1;33m%s\033[0m\n" "$*"; }
red()    { printf "\033[1;31m%s\033[0m\n" "$*" >&2; }

find_python() {
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1; then
      echo "$candidate"
      return
    fi
  done
  red "Python 3.10+ is required but was not found."
  exit 1
}

setup_venv() {
  local py
  py="$(find_python)"
  if [ ! -d "$VENV_DIR" ]; then
    yellow "Creating virtual environment in $VENV_DIR ..."
    "$py" -m venv "$VENV_DIR"
  fi
  # shellcheck disable=SC1091
  if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
  else
    source "$VENV_DIR/Scripts/activate"   # Git Bash on Windows
  fi
  yellow "Installing dependencies ..."
  python -m pip install --quiet --upgrade pip
  python -m pip install --quiet -r requirements.txt
}

run_tests() {
  setup_venv
  green "Running tests ..."
  python manage.py test
}

run_local() {
  setup_venv
  python manage.py check
  green "Zing It is running at http://127.0.0.1:${PORT}  (Ctrl+C to stop)"
  DJANGO_DEBUG=True python manage.py runserver "0.0.0.0:${PORT}"
}

run_prod() {
  setup_venv
  export DJANGO_DEBUG=False
  python manage.py collectstatic --noinput >/dev/null
  green "Zing It (Gunicorn) is running at http://127.0.0.1:${PORT}  (Ctrl+C to stop)"
  gunicorn django_project.wsgi:application --bind "0.0.0.0:${PORT}" --workers 2 --access-logfile -
}

run_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    red "Docker is not installed. Get it from https://docs.docker.com/get-docker/"
    exit 1
  fi
  yellow "Building image '${IMAGE_NAME}' ..."
  docker build -t "$IMAGE_NAME" .
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  docker run -d --name "$CONTAINER_NAME" -p "${PORT}:8000" "$IMAGE_NAME" >/dev/null
  green "Zing It is running in Docker at http://127.0.0.1:${PORT}"
  echo "  Logs:  docker logs -f ${CONTAINER_NAME}"
  echo "  Stop:  ./run.sh docker-stop"
}

stop_docker() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 && green "Container stopped." || yellow "No container named '${CONTAINER_NAME}' is running."
}

case "${1:-local}" in
  local)        run_local ;;
  prod)         run_prod ;;
  test)         run_tests ;;
  docker)       run_docker ;;
  docker-stop)  stop_docker ;;
  -h|--help|help)
    sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
    ;;
  *)
    red "Unknown command: $1"
    echo "Run ./run.sh help for usage."
    exit 1
    ;;
esac
