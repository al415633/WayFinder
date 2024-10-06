<img src="./assets/logo.png" alt="Wayfinder Logo" width="50" align="left">

# Wayfinder - Spike 0

Este proyecto forma parte del desarrollo del **Spike 0** de la aplicación **Wayfinder**, un sistema de movilidad que calcula rutas optimizadas entre diferentes puntos de interés utilizando varios métodos de transporte. Este Spike tiene como objetivo investigar y probar tecnologías clave antes del desarrollo completo.

## Autores de la aplicación

- **Miembro 1** - Ángela Ausina Sánchez
- **Miembro 2** - Andrea Belen Cretu Toma
- **Miembro 3** - Miriam Llorens Montañés
- **Miembro 4** - Alejandro Tendero Ferrandis

## Objetivo del Spike

El Spike 0 está diseñado para explorar y validar las tecnologías necesarias para el desarrollo de la aplicación. El propósito es asegurarse de que las APIs seleccionadas, herramientas de mapas y frameworks funcionan según lo esperado, sin centrarse en la funcionalidad final.

### Funcionalidades Exploradas

- **Cálculo de rutas**: Conexión inicial con la API de **OpenRouteService** para calcular rutas entre dos puntos dados.
- **Visualización de mapas**: Uso de **Leaflet.js** para mostrar mapas interactivas con las rutas generadas.
- **Geocoding**: Obtención de coordenadas a partir de nombres de lugares utilizando la API de geocoding.
- **Persistencia de datos**: Exploración de bases de datos utilizando **PostgreSQL** para almacenar rutas y lugares de interés.
- **Coste asociado**: Cálculo básico del coste del trayecto según el método de transporte (combustible, electricidad, calorías).

## Tecnologías Utilizadas

- **Frontend**: **Flutter** para el desarrollo de la interfaz gráfica de usuario en aplicaciones móviles.
- **API Externas**:
  - [OpenRouteService](https://openrouteservice.org/): Para el cálculo de rutas y geocoding.
  - [Datos.gob.es](https://datos.gob.es/es/catalogo/e05068001-precio-de-carburantes-en-las-gasolineras-espanolas): Para obtener precios de carburantes en España.
  - [Preciodelaluz.org](https://api.preciodelaluz.org): Para obtener precios de la electricidad en España.
- **Persistencia**: Base de datos **PostgreSQL** para almacenar rutas, usuarios y configuraciones.
- **Integración de Mapas**: Uso de **Leaflet.js** para mostrar mapas interactivos en el frontend.

## Contribuir al Proyecto

En este proyecto utilizamos una metodología basada en **Gitflow** para trabajar de forma colaborativa y organizada. A continuación te explicamos cómo contribuir correctamente.

### Buenas Prácticas para Commits
Seguimos el formato de **Conventional Commits** para que todos los mensajes de commit sean claros y consistentes. El formato a seguir es:

```bash
<type>(<scope>): <description>
```

- **type**: Tipo de cambio, puede ser uno de los siguientes:
  - `test`: cambios relacionados con las pruebas.
  - `feat`: cambios que introducen una nueva funcionalidad al proyecto.
  - `refactor`: cambios que introducen modificaciones para optimizar el diseño de funcionalidades previamente implementadas.
  - `fix`:  cambios para arreglar bugs.
  - `chore`: cambios relacionados con la configuración del proyecto. Por ejemplo, añadir/modificar dependencias.

- **scope**: indica donde se producen los cambios . En nuestro caso lo vamos a usar para indicar a que iteración e historia pertenece el commit. Lo indicaremos de la siguiente forma: itnnhxx, donde nn será en número de iteración y xx el número de historia.

- **description**: breve descripción de los cambios introducidos en el commit, en inglés. Intentad utilizar descripciones cortas y concisas, pero que aporten información .Si no sois capaces de describir los cambios que incluye el commit de forma concisa y breve es posible que necesitéis separar los cambios en varios commits.

### Ramas de Trabajo
- **Rama principal (`main`)**: Contiene solo versiones estables del proyecto. No se trabaja directamente en esta rama.
- **Ramas de iteración (`it-nn`)**: Cada iteración del desarrollo tiene su propia rama. Por ejemplo, la tercera iteración se trabaja en la rama `it-03`. Aquí se fusionan todas las historias de esa iteración.
- **Ramas de historia (`h-xx`)**: Cada historia o funcionalidad tiene su propia rama. Por ejemplo, la historia 5 en la tercera iteración se trabaja en la rama `h-05`. Los cambios de cada historia se implementan en su propia rama.

### Flujo de Trabajo
1. **Crear una rama de iteración**: Al comenzar a trabajar en una iteración, crea una nueva rama desde la rama de main:
   ```bash
   git checkout -b it-01

2. **Crear una rama de historia**: Al comenzar a trabajar en una historia, crea una nueva rama desde la rama de la iteración correspondiente:
   ```bash
   git checkout -b h-05

3. **Hacer un pull request**: Al acabar de programar la funcionalidad deseada, abre un PR para que todos los miembros del equipo puedan revisar tus cambios
   `IT03-H05: Implement user login functionality`

4. **Revisión y fusión**: El equipo revisará los cambios en la PR. Si todo está en orden, se aprobará la PR y los cambios se fusionarán con la rama de iteración (`it-nn`):
   ```bash
   git checkout it-03
   git merge h-05
   ```

5. **Fusión a main**: Una vez que todas las historias de una iteración estén completas y revisadas, se abrirá una PR para fusionar la rama de iteración con la rama principal (main). Esta fusión solo debe ocurrir cuando se haya comprobado que la iteración es estable.
   ```bash
   git checkout main
   git merge it-03  
   ```


## Estructura del Proyecto

```bash
├── src
│   ├── frontend    # Lógica de la interfaz de usuario y la integración con Flutter
│   ├── backend     # Lógica de negocio y conexión con APIs externas
│   └── tests       # Pruebas automatizadas ATDD
└── README.md
```

