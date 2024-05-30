# **LettecBoxD**
## Proyecto final U4 y U5
### Idea del Proyecto

La aplicación está diseñada como una plataforma para que los usuarios puedan ver, revisar y comentar sobre películas. Los usuarios pueden crear cuentas, iniciar sesión, agregar sus reseñas y ver las reseñas de otros usuarios. Además, cuenta con funcionalidades especiales para administradores, quienes pueden gestionar la base de datos de películas.

### Modelado de las Colecciones

#### Usuarios (`users`)

- **Campos**:
  - `uid` (String): Identificador único del usuario.
  - `username` (String): Nombre de usuario.
  - `email` (String): Correo electrónico del usuario.
  - `role` (String): Rol del usuario (`admin` o `regular`).
  - `profilePicture` (String): URL de la imagen de perfil del usuario.
  - `bannerPicture` (String): URL de la imagen del banner del usuario.

#### Películas (`movies`)

- **Campos**:
  - `name` (String): Nombre de la película.
  - `director` (String): Director de la película.
  - `year` (int): Año de lanzamiento.
  - `genre` (String): Géneros de la película, separados por comas.
  - `description` (String): Descripción de la película.
  - `moviePosterPath` (String): Ruta del póster en Firebase Storage.
  - `movieBannerPath` (String): Ruta del banner en Firebase Storage.

#### Reseñas (`reviews`)

- **Campos**:
  - `movieId` (String): Identificador de la película.
  - `userId` (String): Identificador del usuario que hizo la reseña.
  - `rating` (int): Calificación de la película.
  - `reviewText` (String): Texto de la reseña.
  - `likes` (int): Número de likes de la reseña.
  - `createdAt` (Timestamp): Fecha y hora en que se creó la reseña.

### Uso de Firebase Storage

Firebase Storage se utiliza para almacenar las imágenes de los pósters y banners de las películas, así como las imágenes de perfil y banners de los usuarios. Los archivos se organizan en carpetas según su tipo:

- **Carpeta de Posters**: Almacena las imágenes de los pósters de las películas.
- **Carpeta de Banners**: Almacena las imágenes de los banners de las películas y los banners de los usuarios.
- **Carpeta de Perfiles**: Almacena las imágenes de perfil de los usuarios.

### Manejo de Usuarios

#### Registro de Usuario

1. **Formulario de Registro**: El usuario completa un formulario con su correo electrónico, nombre de usuario, contraseña e imagen de perfil.
2. **Creación en Firebase Authentication**: Se crea un nuevo usuario en Firebase Authentication.
3. **Almacenamiento en Firestore**: Se almacena la información del usuario en la colección `users` en Firestore.

#### Inicio de Sesión

1. **Formulario de Inicio de Sesión**: El usuario ingresa su correo electrónico y contraseña.
2. **Autenticación con Firebase**: Se verifica la autenticación del usuario utilizando Firebase Authentication.
3. **Redirección a la Página Principal**: Según el rol del usuario, se le redirige a la página de inicio correspondiente (admin o regular).

#### Perfil del Usuario

1. **Visualización y Edición del Perfil**: Los usuarios pueden ver y editar su perfil, incluyendo su nombre de usuario, imagen de perfil y banner.
2. **Actualización en Firestore y Storage**: Las actualizaciones se reflejan tanto en Firestore como en Firebase Storage.

#### Manejo de Sesiones

1. **Cerrar Sesión**: El usuario puede cerrar sesión desde cualquier página. Se muestra un diálogo de confirmación antes de cerrar la sesión.

### Funcionalidades Clave

#### Reseñas

- **Agregar Reseña**: Los usuarios pueden agregar reseñas a las películas que han visto, incluyendo una calificación y un comentario.
- **Ver Reseñas**: Las reseñas de cada película se muestran en la página de detalles de la película.
- **Like/Dislike Reseñas**: Los usuarios pueden dar like o dislike a las reseñas de otros usuarios.
- **Eliminar Reseña**: Los usuarios pueden eliminar sus propias reseñas con una confirmación de diálogo.

#### Gestión de Películas (Admin)

- **Agregar Películas**: Los administradores pueden agregar nuevas películas a la base de datos, subiendo pósters y banners a Firebase Storage.
- **Editar Películas**: Los administradores pueden editar la información de las películas existentes.
- **Eliminar Películas**: Los administradores pueden eliminar películas de la base de datos, lo que también elimina los archivos relacionados en Firebase Storage.

#### Interfaz de Usuario

- **Página Principal**: La página principal muestra listas de películas categorizadas por género.
- **Página de Detalles de Película**: Muestra la información detallada de la película y las reseñas de los usuarios.
- **Drawer de Navegación**: Permite a los usuarios navegar entre las diferentes secciones de la aplicación, acceder a su perfil y cerrar sesión.

### Implementación Técnica

1. **Flutter**: Utilizado para construir la interfaz de usuario multiplataforma.
2. **Firebase Authentication**: Maneja la autenticación de los usuarios.
3. **Firebase Firestore**: Base de datos NoSQL para almacenar la información de los usuarios, películas y reseñas.
4. **Firebase Storage**: Almacena las imágenes de los pósters, banners y perfiles de usuario.
5. **Estado y Controladores**: Utiliza `StatefulWidgets` y controladores para manejar el estado y la lógica de negocio.