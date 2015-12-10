#!/bin/bash
echo "**Compilando"
make tester
if [ $? -ne 0 ]; then
  echo "**Error de compilacion"
  exit 1
fi
echo "**Corriendo Valgrind"

valgrind --show-reachable=yes --leak-check=full --error-exitcode=1 ./tester
if [ $? -ne 0 ]; then
  echo "**Error de memoria"
  exit 1
fi

echo "**Corriendo diferencias con la catedra"

DIFFER="diff -b -d"
ERRORDIFF=0
$DIFFER salida.caso1.txt salida.caso1.catedra.txt > /tmp/diff1
if [ $? -ne 0 ]; then
  echo "**Discrepancia en el caso 1"
  ERRORDIFF=1
fi
$DIFFER salida.caso2a.txt salida.caso2a.catedra.txt > /tmp/diff2a
if [ $? -ne 0 ]; then
  echo "**Discrepancia en el caso 2 salida implicita"
  ERRORDIFF=1
fi

$DIFFER salida.caso2b.txt salida.caso2b.catedra.txt > /tmp/diff2b
if [ $? -ne 0 ]; then
  echo "**Discrepancia en el caso 2 salida explicita"
  ERRORDIFF=1
fi
$DIFFER salida.casoNa.txt salida.casoNa.catedra.txt > /tmp/diff3a
if [ $? -ne 0 ]; then
  echo "**Discrepancia en el caso N salida implicita"
  ERRORDIFF=1
fi
$DIFFER salida.casoNb.txt salida.casoNb.catedra.txt > /tmp/diff3b
if [ $? -ne 0 ]; then
  echo "**Discrepancia en el caso N salida explicita"
  ERRORDIFF=1
fi
if [ $ERRORDIFF -eq 0 ]; then
  echo "**Todos los tests pasan"
fi
