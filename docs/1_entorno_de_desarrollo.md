# Entorno de desarrollo
Es mejor usar docker porque las versiones son un poco viejas.

Ubicarse en un directorio vacío y crear un Gemfile
```sh
mdkir blast_crm
cd blast_crm
touch Gemfile
```

Agregar el siguiente contenido al Gemfile
```ruby
source 'https://rubygems.org'

gem 'rails', '5.2.3'
```

Crear un Dockerfile
```sh
touch Dockerfile
```

Agregar el siguiente contenido al Dockerfile
```Dockerfile
# Imagen base
FROM ruby:2.6.3

# Establece el directorio de trabajo
WORKDIR /app

# Copia el Gemfile al directorio de trabajo
COPY Gemfile ./

# Ejecuta el comando bundle para instalar las gemas
RUN bundle check || bundle install

# Se agrega y configura un usuario para evitar problemas de permisos en los archivos compartidos entre el host y el
# contenedor. Dar permisos a /usr/local/bundle es para evitar errores al generar la aplicación Rails.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /usr/local/bundle

USER 1000:1000

# Se ejecuta el siguiente comando para que el contenedor quede activo y no finalice inmediatamente
CMD ["tail", "-f", "/dev/null"]
```

Crear el archivo de configuración de docker compose
```sh
touch compose.yaml
```

Agregar el siguiente contenido a compose.yaml
```yaml
services:
  dev:
    build: .
    volumes:
      - .:/app
```

Levantar el contenedor
```sh
docker compose up -d
```
- `-d`: Para que el contenedor se ejecute en segundo plano.

Ingresar al contenedor en ejecución
```sh
docker compose exec -it dev /bin/bash
```

Una vez dentro del contenedor, ejecutar los siguientes comandos
```sh
rails new blast_crm --skip-test # Crear el proyecto Rails
# Si aparece un error relativo a ffi y/o spring, simplemente ignorarlo y seguir con los siguientes pasos
mv blast_crm/* . # Mover el contenido del proyecto creado a la carpeta raiz
mv blast_crm/.gitignore . # Mover archivos ocultos
mv blast_crm/.ruby-version . # Mover archivos ocultos
rm -rf blast_crm # Borrar la carpeta del proyecto
```

Actualizar el Gemfile para evitar algunos errores de incompatiblidad entre gemas
```ruby
# Actualizar la versión de sqlite 3
gem 'sqlite3', '1.4'
# Agregar y especificar las versiones de estas gemas
gem 'sprockets', '< 4.0'
gem 'ffi', '~> 1.15.5'
gem 'mimemagic', '~> 0.3.6'
gem 'marcel', '~> 0.3.3'
```

Actualizar las gemas dentro del contenedor y ejecutar la aplicación para comprobar su funcionamiento
```sh
bundle update
rails s
```

Salir del contendor y apagarlo
```sh
exit
docker compose down
```

Ahora se deben hacer algunos cambios para poder ejecutar Rails.

Actualizar el Dockerfile para copiar el proyecto dentro del contenedor.
```Dockerfile
# Imagen base
FROM ruby:2.6.3

# Establece el directorio de trabajo
WORKDIR /app

# Copia el Gemfile al directorio de trabajo
COPY Gemfile Gemfile.lock ./

# Ejecuta el comando bundle para instalar las gemas
RUN bundle check || bundle install

# Copia el directorio actual del host dentro del directorio de trabajo del contenedor
COPY . .

# Se agrega y configura un usuario para evitar problemas de permisos en los archivos compartidos entre el host y el
# contenedor. Dar permisos a /usr/local/bundle es para evitar errores al generar la aplicación Rails.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /usr/local/bundle

USER 1000:1000

# Ejecuta la aplicación al levantar el contendedor
CMD ["rails", "s", "-b", "0.0.0.0"]
```

Configurar un volumen para las gemas en compose.yaml y mapear el puerto 3000 del contenedor al puerto 3000 del host
```yaml
services:
  dev:
    build: .
    volumes:
      - .:/app
      - gems_data:/usr/local/bundle/gems
    ports:
      - "3000:3000"
volumes:
  gems_data:
```

Levantar el contenedor reconstruyendo la imagen
```sh
docker compose up --build -d
```

- `--build`: Reconstruye la imagen para que tome los cambios del Dockerfile

Acceder a http://localhost:3000/
