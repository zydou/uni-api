FROM python:3.12-slim AS base
ARG UV_PYTHON=/usr/local/bin/python3.12
RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    --mount=from=ghcr.io/astral-sh/uv:0.6,source=/uv,target=/bin/uv \
    uv pip install --no-python-downloads --no-cache -r requirements.txt

# Copy the virtualenv into a distroless image
FROM gcr.io/distroless/cc:latest
ARG CHIPSET_ARCH=x86_64-linux-gnu
COPY --from=base /usr/local/lib/ /usr/local/lib/
COPY --from=base /usr/local/bin/python3.12 /usr/local/bin/
COPY --from=base /lib/${CHIPSET_ARCH}/libz.so.1 /lib/${CHIPSET_ARCH}/
COPY --from=base /lib/${CHIPSET_ARCH}/libsqlite3.so.0 /lib/${CHIPSET_ARCH}/
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    WATCHFILES_FORCE_POLLING=true
COPY . /home
WORKDIR /home
ENTRYPOINT ["python3.12", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--reload", "--reload-include", "*.yaml"]
