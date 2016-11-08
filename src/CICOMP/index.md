---
layout: large-page
---

# Taller Jekyll CICOMP 2016

Jekyll: un generador de blogs y sitios web estáticos.

Está participando en el taller Jekyll en el CICOMP 2016. Gracias por ser conejillo de india en este, mi primer taller. Espero que lo que va a aprender el día de hoy le servirá en el futuro, y si tiene cualquier pregunta o duda por favor hágamelo saber.

Advertencia: No soy experto Jekyll, solo un usuario ocasional. Commencé mi sitio en Jekyll en 2014 y me pareció que era una herramienta muy interesante. Desde entonces ha evolucionado mucho.

## Iniciando con Jekyll

Crear un sitio jekyll nuevo

```bash
jekyll new mi_sitio
```

<!--{% highlight bash%}-->
	<!--jekyll new mi_sitio-->
<!--{% endhighlight %}-->

Entrar al directorio que fue creado

```
cd mi_sitio
```

Veamos que archivos y directorios fueron creados con el comando 

```
ls -la
```

La salida contendrá al menos los archivos y directorios siguientes

```
mi_sitio/
├── about.md
├── index.md
├── _posts/
├── .gitignore
├── _config.yml
└── Gemfile
```

El commando ```jekyll new``` crea un sitio virgen siguiendo la maquetación de Jekyll, junto con el tema por defecto.

Para ver el sitio usemos inicial ejecute

```
jekyll serve
```

Jekyll construye el sitio y arranca un servidor HTTP en la direccion [http://127.0.0.1:4000](http://127.0.0.1:4000).

Note que si usted modifica algún archivo, Jekyll regenera el sitio automáticamente.

## Commandos principales de Jekyll

En Jekyll no hay ninguna base de datos, el sitio se construye a partir de archivos de texto. Los formatos de documento permitidos por Jekyll son html, markdown, textile o liquid. Jekyll lee esos archivos y genera un sitio web html estandard. Otros tipos de archivos también pueden ser usados, pero en ése caso Jekyll no los procesa, los copia tal cual.

```
jekyll serve
```

Jekyll va a construir el sitio y lanza un servidor http localmente.
Para detener el servidor presione ```ctrl+c```.
Por defecto, el sitio generado se encuentra en el directorio ```_site```

<!--<br />-->

```
jekyll build
```

Genera el sitio _sin_ lanzar el servidor http. Por defecto, el sitio generado se encuentra en el directorio ```_site``` pero puede cambiar el destino con la opción ```--destination <destination>```


```
jekyll new
```

Crea el esqueleto de un sitio jekyll con el tema por defecto. Por ejemplo, ```jekyll new mi_super_sitio``` crea un sitio llamado mi_super_sitio.
Por cierto, si descarga un tema Jekyll desde internet, o si se basó en el sitio de alguien más, puede ser que éste paso no sea necesario.


###Resumen de comandos

| commando | descripción |
|------|--------|
|  ```jekyll new nombre_sitio```  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Crea el esqueleto de un sitio nuevo |
|  ```jekyll build ``` | Construye el sitio  |
|  ```jekyll serve ``` | Construye el del sitio y lanza el servidor http |
|  ```jekyll clean ``` | Borrar el sitio generado (solamente afecta el directorio ```_site```) |
|  ```jekyll help ```  | Mostrar la ayuda  |
|  ```jekyll <subcommand> help ```  | Mostrar la ayuda específica del subcommando |


## Estructura de un sitio Jekyll

Vamos a cubrir muy rápidamente la estructura de un sitio jekyll, pero es importante entender cada elemento. Si necesita mayor información consulte la documentación oficial  
[https://jekyllrb.com/docs/structure/](https://jekyllrb.com/docs/structure/)

<hr />
`_config.yml`

Este archivo contiene la configuración general del sitio. Usa un formato muy sencillo llamado yaml.

Edite el archivo para empezar a llenar la información del sitio, puede comenzar por llenar el titulo del sitio, su correo electrónico, su usuario github (vamos a crear uno después si aun no tiene), usuario twitter, la descripción del sitio, etc.  
[https://jekyllrb.com/docs/configuration/](https://jekyllrb.com/docs/configuration/)

<hr />
`index.md`

Esta es la página de inicio de su nuevo blog. Vea el contenido del archivo y note que inicia con un encabezado YAML. Las líneas que comienzan con `#` son comentarios.

```yaml
---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---
```

Todo archivo que tenga un encabezado YAML sera transformado por jekyll al construir su sitio, no importa si es un archivo .html, .markdown, .md, o .textile. Veremos más tarde este proceso, pero en este encabezado está claramente indicado que el diseño usado es `home`.

Note que los archivos que no tienen un encabezado YAML serán copiados tal cual al sitio final. Esto le permite mezclar todo tipo de contenido en su sitio, o incluir archivos como imagenes o pdfs.  
[https://jekyllrb.com/docs/frontmatter](https://jekyllrb.com/docs/frontmatter/)

<hr />
`_layouts`

El directorio `_layouts` contiene los diseños de las páginas y las entradas de blog del sitio. La idea es que éstos archivos definen el diseño de cada tipo de página, y en el encabezado YAML uno define cual diseño usar. Un diseño va a proveer el código html y markdown que _envuelve_ la página o la entrada de blog que escribe. Los diseños tienen derecho de incluir pedazos de código del directorio `_includes`.

El tema por defecto, `minima`, tiene los diseños `default`, `home`, `page`, y `post`. Usted puede agregar los diseños que quiera, se puede basar en los diseños existentes (copiar y modificar los archivos de diseño del tema).


<hr />
`_includes`

Este directorio contendra los pedazos reutilizables de sus plantillas ("templates"). A veces se les conoce como parciales. Es común tener archivos con código html parcial para las cabezeras o pie de pǽginas, así como las barras de navegación.
Veremos más sobre como funcionan, en particular cuando usemos temas diferentes.


<hr />
`_posts`

Este directorio contendrá las entradas de su blog. El término 'blog' es flexible, hay muchos sitios que usan este directorio para entradas nuevas del sitio sin ser necesariamente un blog.

Cada entrada de blog debe ser contenido dentro de un archivo cuyo nombre deberá seguir el formato,
`YEAR-MONTH-DAY-this-is-my-title.MARKUP`. El directorio puede contener un gran nombre de entradas, cada uno en un archivo independendiente.

Por ejemplo, `2016-11-11-mi-primer-blog.md` es una entrada de blog válida siguiendo el formato markdown.


<hr />
`about.md`

El tema por defecto viene con éste archivo en el directorio principal del proyecto.  La ubicación del archivo puede ser molesto y no convenir a sus preferencias de organización del sitio por lo que muchos temas lo mueven de directorio. Recuerda que usted controla la ubicación de todos los archivos y el url en el que serán publicados.

<hr />
`_site`

Este directorio contiene el sitio estático generado por Jekyll. Puede navegar en el directorio y ver todos los archivos. Es importante notar que los archivos que tenían encabezados YAML ahora son archivos .html completos.

Cada vez que modifique un archivo, jekyll va a borrar y recrear este directorio. Es importante que no haga cambios directamente a los archivos que contiene por que serán perdidos.

**Compare el contenido y la ubicación de los archivos de su proyecto con respecto a los que son generados en`_site`.**

Por ejemplo,  
`index.md --> _site/index.html`  
`about.md --> _site/about/index.html`  
`_posts/2016-11-05-welcome-to-jekyll.markdown --> _site/jekyll/update/2016/11/05/welcome-to-jekyll.html`

Todos los URL finales son configurables, ya sea por su ubicación en el proyecto, o por que cambia la propiedad `permalink` del encabezado YAML.

<hr />
`_data`

Pondremos elementos reutilisables, variables, y otras cosas en este directorio. Los datos pueden estar en archivos YAML, JSON o CSV.

Otros directorios

Si usted crea otros directorios, como por ejemplo un directorio img que contiene sus imágenes, estos serán copiados al sitio final.

<hr />
`Gemfile`

Este archivo contiene las dependencias ruby para su sitio. Sirve para descargar y usar extensiones, plugins, temas y otras cosas.  
[http://jekyll.tips/jekyll-casts/gemfiles-and-the-bundler/](http://jekyll.tips/jekyll-casts/gemfiles-and-the-bundler/)

## pages vs posts

Existen dos tipos de página web en Jekyll, "pages" y "posts", o sea, pǽginas "normales" y entradas de blog.

La particularidad de las entradas de blog son que deben de estar en el directorio de `_posts`, deben de nombrarse siguiendo las reglas descritas arriba con respecto a la fecha, son listados cronológicamente, y pueden pertenecer a categorías.  
[https://jekyllrb.com/docs/posts/](https://jekyllrb.com/docs/posts/)

Las páginas son especialmente útiles para páginas principales del sitio donde el URL es importante.  
[https://jekyllrb.com/docs/pages/](https://jekyllrb.com/docs/pages/)

##Ejemplo de markdown

El código fuente de ésta página se encuentra aquí  
[https://raw.githubusercontent.com/rudametw/rudametw.github.io/master/src/CICOMP/index.md](https://raw.githubusercontent.com/rudametw/rudametw.github.io/master/src/CICOMP/index.md)

## Temas y estilos

###¿Donde está instalado su tema ?

Por defecto Jekyll usa el tema minima. Para ver donde está instalado puede usar el comando 

```bash
bundle show minima
```
Cuando sepa donde está instalado el tema, puede ver su contenido con el comando `ls`, como por ejemplo 

```
ls -la /usr/lib/ruby/gems/2.3.0/gems/minima-2.0.0
```

Pude usar el comando `cd` para navegar al directorio y de ahi ver el contenido del tema. También puede usar un navegador de archivos gráfico como Nautilus para abrir el directorio.

```
nautilus /usr/lib/ruby/gems/2.3.0/gems/minima-2.0.0
```

**Estudie el contenido de los directorios `_layouts` y `_includes`**

<hr />
###Cambiar de tema

Dentro del archivo `_config.yml` puede cambiar o borrar la propiedad `theme: minima`. Recuerda que al cambiar el tema, los diseños (dentro del directorio `_layout`) pueden cambiar de nombre.

El tema también se puede sobreescribir si usted tiene archivos del mismo nombre y ubicación en su proyecto. Por ejemplo, si está usando un tema que le conviene pero que quiere modificar ligeramente, puede copiar los archivos del tema que desea modificar a su proyecto, y luego hacer las modificaciones pertinentes.

<hr />
####Sin tema

Borre la propiedad `theme:`. Jekyll solo usará los elementos existentes dentro de su proyecto (usted deberá proveer todo los archivos de diseño). 

<hr />
####Instalando gems

La comunidad ruby provee una gran cantidad de paquetes que son facilmente instalables desde su repositorio central. Algunos temas Jekyll también están disponibles, por lo que puede instalarlos desde ahí.

Para instalar un tema, necesita conocer el nombre del tema, y seguir las instrucciones disponibles aquí: [https://jekyllrb.com/docs/themes/](https://jekyllrb.com/docs/themes/)

Un ejemplo que pueden seguir, el tema `starving-artist-jekyll-theme`  
[https://chrisanthropic.github.io/starving-artist-jekyll-theme/documentation/installation/](https://chrisanthropic.github.io/starving-artist-jekyll-theme/documentation/installation/)

Otro ejemplo que puede seguir [https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/)

La lista de gems los puede encontrar en [http://bestgems.org/search?q=jekyll+theme](http://bestgems.org/search?q=jekyll+theme)

Otra lista aquí [https://github.com/planetjekyll/awesome-jekyll-themes#official-themes](https://github.com/planetjekyll/awesome-jekyll-themes#official-themes)

<hr />
####Descargando archivos zip

Hay una gran cantidad de temas para Jekyll que no existen como gems. Para usar esos temas, basta descargar el archivo, descomprimirlo, y copiar los archivos a los directorios correspondientes de su sitio.

Listas de temas :  
[https://drjekyllthemes.github.io/](https://drjekyllthemes.github.io/)  
[http://jekyll.tips/templates/](http://jekyll.tips/templates/)  
[http://themes.jekyllrc.org/](http://themes.jekyllrc.org/)  
[https://jekyllthemes.io/](https://jekyllthemes.io/)
[]()


<hr />
####Descargando proyectos github

El proceso es similar a los archivos zip, es solo que la forma de descargar el proyecto es diferente. Deberá clonar el repositorio con el comando `git clone`, y de ahí copiar los archivos a su sitio, o copiar los archivos de su sitio al repositorio clonado.


##Ejercicio Jekyll

* Escriba 2 o 3 entradas de blog
  * Use markdown
    * Cree una lista numerotada
    * Cree enlaces hace otros sitios
    * Agregue imagenes
		* Crea un directorio para almacenarlos
		* Utilize ligas para apuntar hacía sus imágenes
    * Agregue un video youtube
	* Agrega ejemplos de código
* Escriba 3 páginas (e.g., página inicial, contacto, acerca de)
	* Mezcle contenido markdown y contenido html
	* Intente usar la opción `permalink` para definir un URL diferente para una de las páginas
* Escoge un tema nuevo
	* Cambia el tema por defecto Jekyll
	* Verifique que las páginas y las entradas del blog siguen siendo visibles
		* Corrija los errores en caso de no ser así

Ligas para ayudar :  
[https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)  
[https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)  
[http://www.simplehtmlguide.com/cheatsheet.php](http://www.simplehtmlguide.com/cheatsheet.php)
[]()
[]()

<hr />
#Git
Git (pronunciado "guit" ) es un software de control de versiones diseñado por Linus Torvalds, pensando en la eficiencia y la confiabilidad del mantenimiento de versiones de aplicaciones cuando éstas tienen un gran número de archivos de código fuente.

##Tutorial git (15 minutos)

[https://try.github.io](https://try.github.io)

##Documentación
[https://git-scm.com/book/es/v1](https://git-scm.com/book/es/v1)  
[https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf](https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf)  
[https://www.git-tower.com/blog/git-cheat-sheet/](https://www.git-tower.com/blog/git-cheat-sheet/)

##Github
GitHub es una forja (plataforma de desarrollo colaborativo) para alojar proyectos utilizando el sistema de control de versiones Git. Utiliza el framework Ruby on Rails por GitHub, Inc. (anteriormente conocida como Logical Awesome). Desde enero de 2010, GitHub opera bajo el nombre de GitHub, Inc. El código se almacena de forma pública, aunque también se puede hacer de forma privada, creando una cuenta de pago.

Github se puede ver como una red social para compartir código fuente, es decir, "social coding".

Para continuar, necesitará crear una cuenta github.  
[https://github.com/](https://github.com/)

##Github Pages

Github provee un servicio de hospedaje gratis para sus usuarios que se integra bien con Jekyll. Para usarlo debe de crear un repositorio llamado `usuario.github.io, donde usuario es su nombre de usuario github.

Para empezar una página github-pages, siga los pasos siguientes reemplazando usuario/username por su usuario github : [https://pages.github.com/](https://pages.github.com/)

```
git clone https://github.com/username/username.github.io
cd username.github.io
echo "Hello World" > index.html

git add --all
git commit -m "Initial commit"
git push -u origin master
```
Abra el url que corresponde a su página, [http://username.github.io](http://username.github.io)



Crear una cuenta github  
Crear un repositorio para el codigo del proyecto  
Crear un repositorio para el sitio

Copiar los archivos del directorio _site al repositorio del sitio





<hr />

# Funciones avanzadas

Información sobre el tiempo de generación de paginas

```
jekyll build –profile
```

##Aprenda Liquid
[http://jekyll.tips/jekyll-casts/introduction-to-liquid/](http://jekyll.tips/jekyll-casts/introduction-to-liquid/)  
[http://jekyll.tips/jekyll-casts/control-flow-statements-in-liquid/](http://jekyll.tips/jekyll-casts/control-flow-statements-in-liquid/)  
[https://shopify.github.io/liquid/](https://shopify.github.io/liquid/)  
[]()

Ejemplo de loop con liquid para listar todas las entradas del blog

```
{% raw  %}
<ul>
  {% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
{% endraw %}
```

Jekyll variables  
[http://jekyll.tips/jekyll-cheat-sheet/](http://jekyll.tips/jekyll-cheat-sheet/)

Jekyll Liquid cheat sheet :  
[https://gist.github.com/smutnyleszek/9803727](https://gist.github.com/smutnyleszek/9803727)

##Plugins

[https://jekyllrb.com/docs/plugins/](https://jekyllrb.com/docs/plugins/)

[http://jekyll.tips/jekyll-casts/using-jekyll-plugins/](http://jekyll.tips/jekyll-casts/using-jekyll-plugins/)

##Templates
[https://jekyllrb.com/docs/templates/](https://jekyllrb.com/docs/templates/)

<!--Tree :-->

<!--```-->
<!--project-name/-->
<!--├── _assets/-->
<!--├── _data/-->
<!--├── _drafts/-->
<!--├── _includes/-->
<!--├── _layouts/-->
<!--├── _pages/-->
<!--|   ├── 404.md               # custom 404 page-->
<!--|   ├── about.md             # about page-->
<!--|   ├── contact.md           # contact page-->
<!--|   └── home.md              # home page (eg. <root>/index.html)-->
<!--├── _posts/-->
<!--├── .gitignore-->
<!--├── _config.yml-->
<!--└── Gemfile-->
<!--```-->
<!--Examples: about.md ~> permalink: /about/, home.md ~> permalink: /, contact.md ~> permalink: /contact/, etc.-->


