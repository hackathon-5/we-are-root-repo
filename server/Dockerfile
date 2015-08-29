FROM python:3-onbuild
EXPOSE 8000
RUN ls
CMD gunicorn -b 0.0.0.0:8000 run:gitapp