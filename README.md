# Task Manager Platform

Репозиторий учебного проекта по работе с контейнеризированными приложениями. В составе находятся два сервиса (Flask backend и статический frontend), Helm-чарт для деплоя в Kubernetes и GitHub Actions для CI/CD.

## Содержание репозитория

- `backend/` — исходный код API, тесты и Dockerfile.
- `frontend/` — статический интерфейс на базе Nginx и соответствующий Dockerfile.
- `charts/task-manager/` — Helm-чарт, повторяющий инфраструктуру docker-compose.
- `docker-compose.yml` — конфигурация локальной разработки с MySQL и Redis.
- `.github/workflows/` — рабочие процессы CI/CD.
- `task_2.md`, `ci_cd_plan.md` — формулировка задания и план выполнения.

## Экосистема локальной разработки

**Минимальные зависимости:** Docker Desktop или Docker Engine с docker-compose v2.

Последовательность действий отражена через примеры команд:

- клонирование репозитория и переход в каталог
   ```bash
   git clone <repo-url>
   cd Working-with-containerized-applications
   ```
- сборка и запуск контейнеров вместе с зависимостями
   ```bash
   docker compose up --build
   ```

После запуска сервис фронтенда становится доступным по адресу <http://localhost:8080>, а REST API — по адресу <http://localhost:8080/api/tasks> благодаря проксированию Nginx.

Файл `docker-compose.yml` содержит параметры здоровья, порядок запуска и два сетевых сегмента: `frontend_net` для клиента и `backend_net` для работы backend с MySQL/Redis.

## Развёртывание в Kubernetes через Helm

**Необходимые инструменты:** kubectl, Helm 3, доступ к кластеру (включая локальный minikube).

Переход от контейнеров к кластеру выражен через следующие команды:

```bash
helm upgrade --install task-manager charts/task-manager \
   --namespace task-manager \
   --create-namespace
```

Мониторинг кластера в пространстве имён `task-manager` иллюстрируется примерами:

```bash
kubectl get pods -n task-manager
kubectl get svc -n task-manager
```

При необходимости параметры Helm-чарта (образы, переменные окружения, типы сервисов) переопределяются через `--set` или отдельные values-файлы.

## CI/CD на GitHub Actions

Репозиторий содержит два ключевых workflow:

1. **`PR Checks` (`.github/workflows/pr-checks.yml`)** — реагирует на Pull Request в `master`, выполняет линтинг и тесты backend, линтинг frontend (ESLint), а также пробную сборку Docker-образов.
2. **`Build & Deploy` (`.github/workflows/deploy.yml`)** — активируется при push в `master` или при ручном запуске. Автоматически собирает и публикует образы в GitHub Container Registry (`ghcr.io`), пакует Helm-чарт и создаёт GitHub Release, после чего выполняет `helm upgrade --install` в целевом кластере.

### Секреты GitHub Actions

| Secret            | Назначение                                                     |
|-------------------|----------------------------------------------------------------|
| `GHCR_USERNAME`   | Учетная запись GitHub для доступа к ghcr.io.                  |
| `GHCR_TOKEN`      | Персональный токен с правами `write:packages`.                |
| `KUBE_CONFIG`     | Base64-кодированный kubeconfig удалённого кластера.           |

Workflow выполняются на стандартных `ubuntu-latest` hosted runners, дополнительная настройка раннеров не требуется.

## Публикация артефактов

- Docker-образы публикуются в `ghcr.io/vainarito/task-manager-backend` и `ghcr.io/vainarito/task-manager-frontend` с тегами `latest` и `sha-<commit>`.
- Helm-чарт упаковывается и добавляется в раздел GitHub Release (тег `v<run_number>`), что упрощает загрузку артефактов.

## Проверка и тестирование

- Backend покрывается тестами `pytest` (см. `backend/tests`). Пример запуска в локальной среде:
   ```bash
   python -m pip install -r backend/requirements.txt
   pytest -q backend/tests
   ```
- Frontend содержит статический код и проверяется ESLint в рамках CI:
   ```bash
   npm install --prefix frontend --no-audit --prefer-offline
   npx --prefix frontend eslint frontend
   ```

## Быстрый старт (Docker Compose)

Зависимости: Docker Desktop или Docker Engine с docker-compose v2.

Клонирование и переход в каталог:
```bash
git clone <repo-url>
cd Working-with-containerized-applications
```

Сборка и запуск контейнеров:
```bash
docker compose up --build
```

Доступ к сервисам:
- интерфейс: http://localhost:8080
- API через прокси: http://localhost:8080/api/tasks

Остановка стека:
```bash
docker compose down
```

## Инструкция для тестирования (локально)

Проверка API через curl:

1) список задач — пустой список и код 200
```bash
curl -i http://localhost:8080/api/tasks
```

2) создание задачи
```bash
curl -i -X POST http://localhost:8080/api/tasks \
   -F "title=Test Task" -F "description=Desc" -F "status=New"
```

3) переключение статуса
```bash
TASK_ID=$(curl -s http://localhost:8080/api/tasks | jq -r '.[0].id')
curl -i -X PATCH http://localhost:8080/api/tasks/$TASK_ID
```

4) удаление задачи
```bash
curl -i -X DELETE http://localhost:8080/api/tasks/$TASK_ID
```

## Развёртывание в Kubernetes (Helm)

Инструменты: kubectl, Helm 3, kubeconfig к целевому кластеру.

Установка/обновление релиза:
```bash
helm upgrade --install task-manager charts/task-manager \
   --namespace task-manager \
   --create-namespace
```

Просмотр состояния:
```bash
kubectl get pods -n task-manager
kubectl get svc -n task-manager
```

Сервис фронтенда в значениях по умолчанию — NodePort 30080; для minikube URL выводится командой `minikube service`.

## CI/CD (GitHub Actions)

`PR Checks`: линт и тесты backend, линт frontend, пробная сборка Docker‑образов.

`Build & Deploy`: сборка и публикация образов в GHCR, упаковка Helm‑чарта, релиз в GitHub, деплой/обновление релиза в Kubernetes.

Секреты:

| Secret          | Назначение                                   |
|-----------------|-----------------------------------------------|
| `GHCR_USERNAME` | учётная запись GitHub для доступа к ghcr.io   |
| `GHCR_TOKEN`    | токен с правами `write:packages`              |
| `KUBE_CONFIG`   | kubeconfig в Base64 для подключения к кластеру|

## Конфигурация и переменные окружения

Backend:
- `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DB` — параметры MySQL
- `REDIS_HOST`, `REDIS_PORT` — параметры Redis
- `FE_HOST` — хост фронтенда для CORS (по умолчанию `localhost:8080`)

Frontend:
- `API_URL` — адрес API в браузере (пустое значение приводит к использованию адреса страницы)
- `INTERNAL_BACKEND_HOST`, `INTERNAL_BACKEND_PORT` — адрес backend для проксирования в Nginx

## Устранение неполадок

Docker Compose:
```bash
docker compose ps
docker compose logs -f backend
docker compose logs -f frontend
```

Проверка точки здоровья backend:
```bash
curl -i http://localhost:8080/health || curl -i http://localhost:5000/health
```

Kubernetes:
```bash
kubectl get pods -n task-manager
kubectl logs -n task-manager deploy/task-manager-backend
kubectl logs -n task-manager deploy/task-manager-frontend
helm status task-manager -n task-manager
```

---

## K8s: способы запуска и доступ

Варианты кластера:
- локальный кластер на базе minikube;
- удалённый кластер (managed/он‑прем), доступ — через kubeconfig.

Примеры команд для minikube (иллюстрация типового сценария):
```bash
# запуск кластера
minikube start

# установка/обновление релиза из этого репозитория
helm upgrade --install task-manager charts/task-manager \
   --namespace task-manager \
   --create-namespace

# публикация URL до фронтенда при типе NodePort (по умолчанию 30080)
minikube service --namespace task-manager task-manager-frontend --url
```

Для сред с ограниченным доступом возможен проброс порта:
```bash
kubectl -n task-manager port-forward svc/task-manager-frontend 8080:80
# интерфейс: http://localhost:8080
```

---

## Настройка CI runner

Варианты раннеров GitHub Actions:
- hosted‑раннеры `ubuntu-latest` (используются по умолчанию в workflow);
- self‑hosted runner (опционально, при необходимости выполнения задач в локальной сети).

Self‑hosted runner (пример регистрации, нейминг и токен предоставляются GitHub):
```bash
# загрузка дистрибутива раннера (Linux x64)
curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v<version>/actions-runner-linux-x64-<version>.tar.gz
mkdir -p ~/actions-runner && tar xzf actions-runner.tar.gz -C ~/actions-runner

# регистрация раннера (URL репозитория/организации и токен берутся из интерфейса GitHub)
cd ~/actions-runner
./config.sh --url https://github.com/<owner>/<repo> --token <RUNNER_TOKEN>

# запуск как сервис systemd
sudo ./svc.sh install
sudo ./svc.sh start
```

Workflow этого репозитория совместимы с обоими вариантами; для self‑hosted допустимо добавить метку и указать её в `runs-on`.

---

## Репозитории Docker и Helm

Docker‑реестр: GitHub Container Registry (GHCR).

Схема адреса образов:
- backend: `ghcr.io/vainarito/task-manager-backend:{latest|sha-<commit>}`
- frontend: `ghcr.io/vainarito/task-manager-frontend:{latest|sha-<commit>}`

Аутентификация в GHCR (пример, переменные берутся из секции Secrets или локальной среды):
```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
```

Публикация образов автоматизируется workflow `Build & Deploy`; локальная публикация возможна при необходимости:
```bash
docker build -t ghcr.io/<owner>/task-manager-backend:dev ./backend
docker push ghcr.io/<owner>/task-manager-backend:dev
```

Helm‑репозиторий: публикация архива чарта (`.tgz`) в GitHub Release (workflow `release-chart`);

Установка из артефакта релиза (скачивание архива чарта):
```bash
helm install task-manager ./task-manager-<version>.tgz -n task-manager --create-namespace

```

