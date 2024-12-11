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

Renombrar core.gemspec a blast_core.gemspec
