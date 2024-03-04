FROM openmpi-builder as osu-binary-provider

COPY --from=osu-code-provider /code/osu-micro-benchmarks-7.3 /code/osu-micro-benchmarks-7.3

WORKDIR /code/osu-micro-benchmarks-7.3

RUN mkdir /code/osu-micro-benchmarks-7.3/build  \
    && ./configure CC=mpicc CXX=mpicxx --prefix=/code/osu-micro-benchmarks-7.3/build \
    && make \
    && make install \
    && mkdir -p /osu \
    && cp -r /code/osu-micro-benchmarks-7.3/build /osu
