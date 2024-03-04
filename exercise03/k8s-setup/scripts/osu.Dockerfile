FROM mpioperator/base:latest

RUN apt update \
    && apt install -y --no-install-recommends \
        dnsutils \
        mpich \
    && rm -rf /var/lib/apt/lists/*

COPY --from=osu-benchmarks /osu /home/mpiuser/osu
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]