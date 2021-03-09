# PocketPlanetarium
### Creando Interfaces de Usuario - Prácticas 3 y 4



## Introducción
Se pide crear un prototipo que muestre un sistema planetario en movimiento que incluya una estrella, al menos cinco planetas y alguna luna.Tomado esto como punto de partida, se decidió representar el Sistema Solar de manera fidedigna, utilizando valores realistas.

Para poder ejecutar la aplicación se recomienda utilizar los binarios del apartado de Releases, puesto el entorno de Processing puede ralentizar enormemente la ejecución, además de que es necesario lanzar la aplicación con una GPU potente, ya que se usan esferas muy grandes y texturas de muy alta calidad.

### Modo de Exploración
![Exploration Mode](teaser1.gif)


### Modo de Vista General
![General View](teaser2.gif)



## Planetas y órbitas
Para representar las órbitas se tomó la órbita de Kepler como modelo en lugar de una órbita circular, aunque no se terminan de apreciar las elipses puesto que son de excentricidades muy bajas; sí que se aprecia, en cambio, la variación en la velocidad de rotación en los puntos más cercanos/alejados del Sol. Todos los datos han sido recogidos de Wikipedia.

Antes de representar un cuerpo celeste, se representan previamente sus cuerpos orbitantes teniendo en cuenta la inclinación orbital de éste. También se respeta la inclinación axial y los periodos de rotación y orbitación de cada cuerpo por separado.

En el HUD se puede apreciar el equivalente en tiempo real a un día en la Tierra y un año. Por defecto se toma como referencia a que 2s equivalen a 1 día terrestre, aunque se da la posibilidad de acelerar el tiempo para observar la órbita de planetas más lentos como Júpiter.



## Cámara
Se ofrecen dos modos de visualización: la vista general y el modo de exploración. En ambos se hace uso de la librería PeasyCam para Processing, aunque en el modo de exploración se utilizan controles personalizados.

En el modo de exploración se permite recorrer el sistema libremente con una nave (diseño de autoría propia). Dado que las distancias entre los planetas se ha representado de manera medianamente realista, la velocidad que puede alcanzar la nave sobrepasa a la de la luz para poder recorrer el sistema con facilidad.

### PeasyCam
En el modo de vista general se utiliza el funcionamiento por defecto de PeasyCam.

### Cuaterniones
Para el modo de exploración se utiliza un control más preciso de la cámara. Dado que para representar la posición de la nave se utilizan los ángulos de Euler, la traducción inmediata de estos a rotaciones independientes sobre cada eje implica la aparición del efecto giroscópico, perdiendo un eje de libertad al alinearse dos de ellos. Cada vez que el usuario mueve el ratón se actualiza la orientación de la nave, la rotación se realiza utilizando cuaterniones para evitar el efecto giroscópico, creando un rotor para cada vector de dirección de la nave y encadenando las rotaciones.

Estos vectores de dirección de la nave se tienen en cuenta a la hora de moverla. Cuando el usuario decide moverse se toman como referencia, generando un vector de velocidad, el cual se conserva aún cuando el usuario ha dejado de pulsar las teclas, creando así un efecto de inercia.

Existe un fallo provocado por la librería PeasyCam, y es que, a pesar de utilizar correctamente los métodos designados para solventar este problema, el funcionamiento por defecto no se consigue desactivar por lo que, si el usuario mantiene presionado el ratón, se vuelve a la vista general momentáneamente.

### Billboarding
Dado que la imagen utilizada para representar la nave y los nombres de los planetas son bidimensionales, se utiliza la técnica de Billboarding para provocar que éstos siempre miren hacia la cámara. Esto se consigue eliminando las rotaciones previas de la matriz de rotación.


## Iluminación
Existen dos fuentes de iluminación en la escena: una luz ambiental y un punto de luz, ambas situadas en el origen. El punto de luz pretende simular la luz generada por el Sol, creando sombras en los planetas. Para evitar que la textura aplicada al Sol quedase completamente sombreada se aplica una luz ambiental, procurando un decaimiento exponencial para evitar que llegue a los planetas con demasiada intensidad y que no se creen sombras en las caras que no ven el Sol.
