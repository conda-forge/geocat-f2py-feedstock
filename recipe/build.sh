#!/bin/sh

set -e

if [ "$target_platform" = "osx-arm64" ]; then
  export CMAKE_OSX_ARCHITECTURES="arm64"
fi

# fix entry_point -- https://github.com/conda-forge/numpy-feedstock/issues/276
# Uses the python inside the pip build environment
cat > myf2py.sh <<EOF
#!/bin/sh
python -m numpy.f2py.__main__ \$@
EOF
chmod +x myf2py.sh
export SKBUILD_CONFIGURE_OPTIONS="-DBLA_VENDOR=Generic -DF2PY_EXECUTABLE=$PWD/myf2py.sh"

cd src/geocat/f2py/fortran
f2py -c --fcompiler=gnu95 dpres_plevel_dp.pyf dpres_plevel_dp.f
f2py -c --fcompiler=gnu95 grid2triple.pyf grid2triple.f
f2py -c --fcompiler=gnu95 linint2.pyf linint2.f
f2py -c --fcompiler=gnu95 moc_loops.pyf moc_loops.f
f2py -c --fcompiler=gnu95 rcm2points.pyf rcm2points.f rcm2rgrid.f linmsg_dp.f linint2.f
f2py -c --fcompiler=gnu95 rcm2rgrid.pyf rcm2rgrid.f linmsg_dp.f linint2.f
f2py -c --fcompiler=gnu95 triple2grid.pyf triple2grid.f
cd ../../../..

python -m pip install --no-deps --ignore-installed -vv .
