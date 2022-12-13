#!/bin/sh
for f in patches/*; do
    p=$(basename ${f%.diff})
    patch -p1 -d duniverse/$p < $f
done
