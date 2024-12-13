# Módulo Core (Setup)
## Generación y configuración del módulo
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

Se debe agregar el namespace global Blast para poder agrupar un set de módulos bajo un mismo namespace, para eso se requiere
crear también la carpeta blast ya que Rails utiliza esta estructura para determinar el nombre de las clases y namespaces.
La carpeta blast_crm/engines/core/lib contiene el corazón del engine y requiere una pequeña reorganización.
```sh
cd engines/core/lib
mkdir blast
mv core core.rb blast/
touch blast_core.rb
```

Se debe actualizar blast_core.rb y core.rb para que la aplicación padre pueda acceder a los engines.
```ruby
# blast_crm/engines/core/lib/blast_core.rb
require 'blast/core'
```

```ruby
# blast_crm/engines/core/lib/blast/core.rb
require_relative 'core/engine'

module Blast
  module Core
  end
end
```

Agregar el namespace Blast a version.rb
```ruby
# blast_crm/engines/core/lib/blast/core/version.rb
module Blast
  module Core
    VERSION = '0.1.0'
  end
end
```

Cada engine de Rails viene con un archivo llamado engine.rb. Este archivo representa el corazón del engine.
Al cambiar la estructura del engine, se debe agregar el namespace Blast a este archivo y remover el namespace Core del
método isolate_namespace.
```ruby
# blast_crm/engines/core/lib/blast/core/engine.rb
module Blast
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Blast
    end
  end
end
```
El método isolate_namespace está aquí para marcar una clara separación entre los controladores, modelos y rutas del
engine, aislandolos de las entidades de la aplicación padre. Con esto se evitan problemas de conflictos y sobreescrituras.

Renombrar core.gemspec a blast_core.gemspec para que coincida con el namespace que se está usando ahora. Moverse a la 
raíz del engine blast_crm/engines/core y ejecutar
```bash
mv core.gemspec blast_core.gemspec
```

Actualizar blast_core.gemspec
```ruby
# blast_crm/engines/core/blast_core.gemspec
$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "blast/core/version" # Se agrega el namespace blast

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "blast_core"                     # Se renombra core a blast_core
  spec.version     = Blast::Core::VERSION             # Se agrega el namespace Blast
  spec.authors     = ["Rodrigo Fernandez"]            # Tu nombre    
  spec.email       = ["rofaccess@gmail.com"]          # Tu correo   
  spec.homepage    = "https://github.com/rofaccess/blast_crm"
  spec.summary     = "Core features of blast_crm."
  spec.description = "Core features of blast_crm."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
            "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.6"

  spec.add_development_dependency "sqlite3"
end
```

Para que todo funcione bien se necesita actualizar el archivo engines/core/bin/rails. Se debe agregar blast al ENGINE_PATH
```ruby
# blast_crm/engines/core/bin/rails
# ...
ENGINE_PATH = File.expand_path('../lib/blast/core/engine', __dir__)
# ...
```

Agregar el namespace Blast a routes.rb
```ruby
# blast_crm/engines/core/config/routes.rb
Blast::Core::Engine.routes.draw do
end
```

Agregar el módulo core al Gemfile de la aplicación padre o en todo caso actualizarlo si ya existe
```ruby
# blast_crm/Gemfile
# ...
gem 'blast_core', path: './engines/core'
```

Ahora se debe ejecutar bundle install para comprobar que todo funcione correctamente, caso contrario se debe verificar
si todos los cambios fueron ralizados correctamente.
```bash
docker compose run --rm -p 3000:3000 dev bash # Levantar el contenedor e ingresar dentro
bundle install # Se ejecuta esto para comprobar que los cambios realizados funcionen correctamente
rails s -b 0.0.0.0 # Probar la ejecución de la aplicación padre
exit
```
Al ejecutar bundle install se actualizará el archivo Gemfile.lock indicando que el módulo core fue instalado.

El módulo core está ahora integrado a la aplicación padre, pero todavía no es accesible. Para esto hay que montarlo en
el archivo routes.rb de la aplicación padre.
```ruby
# blast_crm/config/routes.rb
Rails.application.routes.draw do
  mount Blast::Core::Engine => '/', as: 'blast'
end
```

Levantar el contenedor y acceder a [localhost:3000](http://localhost:3000/) para comprobar que funciona.
```bash
docker compose up -d
```

## Agregar contenido al módulo
Por ahora se muestra la página por defecto de Rails, por lo que se procederá a agregar algún contenido.

Reestructurar la carpeta controllers
```bash
cd engines/core
mv app/controllers/core app/controllers/blast
```

Actualizar el ApplicationController del engine
```ruby
# blast_crm/engines/core/app/controllers/blast/application_controller.rb
module Blast
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
  end
end
```

Crear un dashboard_controller con un index
```bash
touch app/controllers/blast/dashboard_controller.rb
```

Alternativa usando el generador
```bash
rails g controller dashboard --no-assets --no-helper
```

```ruby
# blast_crm/engines/core/app/controllers/blast/dashboard_controller.rb
module Blast
  class DashboardController < ApplicationController
    def index
    end
  end
end
```

Agregar la ruta
```ruby
# blast_crm/engines/core/config/routes.rb
Blast::Core::Engine.routes.draw do
  root to: "dashboard#index"
end
```

Reestructurar la carpeta views y agregar una vista. Ejecutar los comandos desde la carpeta engines/core.
```bash
mv app/views/layouts/core app/views/layouts/blast
mkdir -p app/views/blast/dashboard
touch app/views/blast/dashboard/index.html.erb
```

Ejecutar la aplicación y acceder a [localhost:3000](http://localhost:3000/) para comprobar que todo funcione correctamente
```bash
docker compose up -d
```

## Estilizar la aplicación
Agregar la gema de Bootstrap y sus dependencias al gemspec del core
```ruby
# blast_crm/engines/core/blast_core.gemspec
# ...
spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.6"

spec.add_dependency 'bootstrap', '~> 4.3.1'
spec.add_dependency 'jquery-rails', '~> 4.3.3'
spec.add_dependency 'sass-rails', '~> 5.0'

spec.add_development_dependency "sqlite3"
```

Al usar las gemas dentro de un engine, estos no se cargan automáticamente. Para cargarlos se debe agregar los require 
dentro del archivo blast_crm/engines/core/lib/blast/core.rb
```ruby
# blast_crm/engines/core/lib/blast/core.rb
require_relative 'core/engine'
require 'sass-rails'
require 'bootstrap'
require 'jquery-rails'

module Blast
  module Core
  end
end
```
Tener esto en cuenta al momento de agregar gemas a los engines.

Habilitar la gema mini_racer e indicar la versión compatible en el Gemfile de la aplicación padre
```ruby
# blast_crm/Gemfile
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', '0.3.1', platforms: :ruby
```
Se requiere instalar esta gema para evitar un error relativo a execjs al momento de acceder a la aplicación.

Actualizar el Dockerfile para que los módulos se puedan instalar. Primero se debe instalar la gemas sin los módulos, luego
se vuelve a llamar a bundle installa para instalar los módulos. Para lograr esto se utiliza una variable de entorno
a la que se denomina INSTALL_MODULES.
```Dockerfile
# Imagen base
FROM ruby:2.6.3

# Establece el directorio de trabajo
WORKDIR /app

# Copia el Gemfile al directorio de trabajo
COPY Gemfile Gemfile.lock ./

# Evita intalar los modulos porque en este punto todavía no se copiaron los módulos
ENV INSTALL_MODULES=false
# Ejecuta el comando bundle para instalar las gemas
RUN bundle check || bundle install

# Copia el directorio actual del host dentro del directorio de trabajo del contenedor
COPY . .

# Se instala los módulos
ENV INSTALL_MODULES=true
RUN bundle install

# Se agrega y configura un usuario para evitar problemas de permisos en los archivos compartidos entre el host y el
# contenedor. Dar permisos a /usr/local/bundle es para evitar errores al generar la aplicación Rails.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /usr/local/bundle

USER 1000:1000

# Ejecuta la aplicación al levantar el contendedor
CMD ["rails", "s", "-b", "0.0.0.0"]
```

También se debe condicionar la instalación de los módulos en el Gemfile
```ruby
if ENV['INSTALL_MODULES'] == 'true'
  gem 'blast_core', path: './engines/core'
end
```

Como se hicieron cambios en el Dockerfile, se requiere reconstruir la imagen mientras se levanta el contenedor
```bash
docker compose up --build
```

Acceder a la aplicación. 

**Obs.:** Si algo falla, se puede probar instalar las gemas manualmente ingresando al contenedor con docker compose run. 
También se puede descomentar la línea command: ["tail", "-f", "/dev/null"] de composable.yml para ejecutar el contenedor 
con docker compose up en modo de espera para luego ingresar al contenedor con docker compose exec.

Probar los siguientes comandos dentro del contenedor facilita la detección de problemas si es que no funciona la aplicación
con docker compose up.
```bash
docker compose run --rm -p 3000:3000 dev bash # Levantar el contenedor e ingresar dentro
bundle install # Se ejecuta esto para comprobar que los cambios realizados funcionen correctamente
rails s -b 0.0.0.0 # Probar la ejecución de la aplicación padre
exit
```

Reorganizar la carpeta assets
```bash
mv app/assets/images/core app/assets/images/blast
mv app/assets/javascripts/core app/assets/javascripts/blast
mv app/assets/stylesheets/core app/assets/stylesheets/blast
```

Renombrar aplicaction.css a application.css.scss
```bash
mv app/assets/stylesheets/blast/application.css app/assets/stylesheets/blast/application.css.scss
```

Importar bootstrap en application.css.scss
```scss
// blast_crm/engines/core/app/assets/stylesheets/blast/application.css.scss
// ...
@import "bootstrap";
```

Cargar los archivos javascript de bootstrap
```js
// blast_crm/engines/core/app/assets/javascripts/blast/application.js
//= require rails-ujs
//= require activestorage
//= require jquery3
//= require popper
//= require bootstrap
//= require_tree .
```

Ya que se reestructuraron los assets se debe actualizar el layout del módulo reemplazando core por blast.
```erb
<-- blast_crm/engines/core/app/views/layouts/blast/application.html.erb -->
<!DOCTYPE html>
<html>
<head>
    <title>Core</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag    "blast/application", media: "all" %>
    <%= javascript_include_tag "blast/application" %>
</head>
<body>

<%= yield %>

</body>
</html>
```

Agregar el siguiente contenido al tag body del layout
```erb
<-- blast_crm/engines/core/app/views/layouts/blast/application.html.erb -->
<nav class="navbar navbar-expand-lg navbar-light bg-light
            navbar-inverse navbar-fixed-top mb-4">
  <%= link_to 'BlastCRM', blast.root_path, class: 'navbar-brand' %>
</nav>

<div class='container' role='main'>
  <%= yield %>
</div>
```

Agregar un título al dashboard
```erb
<-- blast_crm/engines/core/app/views/blast/dashboard/index.html.erb -->
<h2>Dashboard</h2>
<hr>
```

Acceder a la aplicación para ver los cambios

## Resúmen
- Los engines son generados con rails plugin new core --mountable
- Se necesita una aplicación Ruby on Rails vacía para alojar los engines como gemas
- Cuando se usan gemas dentro de un engine, estos deben ser requeridos cuando el engine es cargado.
