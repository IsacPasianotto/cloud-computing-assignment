FROM localhost/my-builder as builder

RUN mkdir -p /osu

COPY --from=osu-code-provider /code/osu-micro-benchmarks-7.3 /osu

WORKDIR /osu


RUN ./configure CC=mpicc CXX=mpicxx --prefix=/usr/local/osu \
    && make \
    && make install

FROM localhost/my-operator as operator

COPY --from=builder /usr/local/osu /home/mpiuser/osu
