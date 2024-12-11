# Módulo Core

Generar un motor montable
```sh
docker compose up -d
docker compose exec -it dev /bin/bash
rails plugin new core --mountable --skip-test
```
Crear una carpeta engines y mover la carpeta core adentro
```sh
mkdir engines
mv core engines/
```
Todos los engines se ubicarán en esta carpeta para mantener el código organizado

Se debe agregar el namespace Blast para poder agrupar un set de módulos bajo un mismo namespace, para eso se requiere
crear también la carpeta blast ya que es la forma de hacer esto en Ruby.
La carpeta blast_crm/engines/core/lib contiene el corazón del engine y requiere una pequeña reorganización.
```sh
cd engines/core/lib
mkdir blast
mv core core.rb blast/
touch blast_core.rb
```
