FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1
WORKDIR /app

RUN useradd -ms /bin/bash pgaiuser

COPY ./requirements.txt /app/
RUN pip3 install --no-cache-dir --disable-pip-version-check --compile --root-user-action=ignore -r requirements.txt

USER pgaiuser
COPY pyproject.toml /app
COPY pgai /app/pgai
ENTRYPOINT ["python", "-m", "pgai", "vectorizer", "worker"]
CMD ["-c", "4"]
