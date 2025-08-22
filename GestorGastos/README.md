# Gestor Integral de Gastos y Presupuestos

Una aplicación iOS gamificada para el control financiero personal que combina la gestión de gastos con elementos de motivación lúdica.

## 🚀 Características Principales

### 💰 Gestión de Gastos
- **Registro rápido**: Agrega gastos manualmente o tomando una foto del recibo
- **Categorización inteligente**: Organiza gastos en categorías predefinidas
- **Escaneo de recibos**: Utiliza la cámara y Vision Framework para extraer información automáticamente
- **Historial completo**: Visualiza todos tus gastos con filtros por categoría y búsqueda

### 📊 Presupuestos y Control
- **Presupuestos por categoría**: Define límites para diferentes tipos de gastos
- **Períodos flexibles**: Configura presupuestos diarios, semanales, mensuales o anuales
- **Alertas visuales**: Recibe notificaciones cuando te acerques o excedas tu presupuesto
- **Seguimiento en tiempo real**: Monitorea tu progreso con barras de progreso dinámicas

### 📈 Reportes y Analytics
- **Gráficos interactivos**: Visualiza tus gastos con gráficos de sectores y líneas
- **Análisis por período**: Compara gastos semanales, mensuales y anuales
- **Tendencias**: Identifica patrones en tus hábitos de gasto
- **Estadísticas detalladas**: Obtén métricas como promedio diario y categorías más utilizadas

### 🎮 Gamificación
- **Sistema de puntos**: Gana puntos por registrar gastos y mantener presupuestos
- **Niveles y progreso**: Avanza de nivel basándote en tu actividad
- **Insignias**: Desbloquea logros por diferentes habilidades financieras
- **Rachas**: Mantén rachas diarias de registro de gastos
- **Perfil personalizado**: Visualiza tu progreso y estadísticas personales

## 🛠 Tecnologías Utilizadas

- **Swift 5.9+**
- **SwiftUI**: Interfaz de usuario moderna y declarativa
- **Core Data**: Persistencia de datos local
- **Vision Framework**: Reconocimiento de texto en recibos
- **Charts Framework**: Gráficos y visualizaciones interactivas
- **PhotosUI**: Selección de imágenes
- **VisionKit**: Escaneo de documentos

## 📱 Requisitos del Sistema

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 🏗 Arquitectura del Proyecto

```
GestorGastos/
├── Models/
│   └── DataModels.swift          # Modelos de datos (Expense, Budget, UserProfile, etc.)
├── Views/
│   ├── MainTabView.swift         # Vista principal con tabs
│   ├── DashboardView.swift       # Panel principal con resumen
│   ├── AddExpenseView.swift      # Formulario para agregar gastos
│   ├── ExpensesListView.swift    # Lista de gastos con filtros
│   ├── ReportsView.swift         # Reportes y gráficos
│   ├── ProfileView.swift         # Perfil y gamificación
│   └── BudgetManagementView.swift # Gestión de presupuestos
├── ViewModels/
│   └── ExpenseManager.swift      # Lógica de negocio y gestión de datos
├── Services/
│   └── PersistenceController.swift # Core Data controller
└── Resources/
    └── Info.plist               # Configuración de la app
```

## 🎯 Funcionalidades por Pantalla

### Dashboard
- Saludo personalizado con nivel del usuario
- Estadísticas rápidas del mes y semana
- Gastos recientes
- Estado de presupuestos
- Indicador de racha actual

### Agregar Gasto
- Formulario intuitivo con validación
- Selección de categoría con iconos
- Captura de fotos desde cámara o galería
- Escaneo de recibos con OCR
- Procesamiento automático de texto

### Lista de Gastos
- Vista filtrable por categoría
- Búsqueda por descripción
- Acciones de deslizar para eliminar
- Ordenamiento por fecha
- Chips de filtro dinámicos

### Reportes
- Gráfico de sectores por categoría
- Gráfico de líneas de tendencias
- Análisis de presupuestos
- Estadísticas de resumen
- Filtros por período

### Perfil
- Información de nivel y puntos
- Progreso al siguiente nivel
- Galería de insignias
- Estadísticas personales
- Configuraciones de la app

### Presupuestos
- Creación de nuevos presupuestos
- Vista de progreso por categoría
- Alertas visuales por exceso
- Gestión de períodos
- Eliminación por deslizar

## 🎮 Sistema de Gamificación

### Puntos y Niveles
- **10 puntos** por cada gasto registrado
- **Niveles**: Cada 1000 puntos = 1 nivel
- **Progreso visual** con barras de progreso

### Insignias Disponibles
1. **Primer Paso** (50 pts): Registra tu primer gasto
2. **Constancia Semanal** (100 pts): 7 días seguidos registrando gastos
3. **Mes Completo** (300 pts): 30 días seguidos registrando gastos
4. **Controlador de Presupuesto** (250 pts): Mantén el presupuesto por un mes
5. **Escáner Pro** (150 pts): Escanea 10 recibos
6. **Organizador** (200 pts): Usa todas las categorías
7. **Ahorrador Experto** (500 pts): Ahorra más del 20% de tu presupuesto

### Rachas
- **Racha actual**: Días consecutivos registrando gastos
- **Mejor racha**: Récord personal de días consecutivos
- **Motivación visual**: Icono de fuego para rachas activas

## 🚀 Instalación y Configuración

1. **Clona o descarga** el proyecto
2. **Abre** `GestorGastos.xcodeproj` en Xcode
3. **Selecciona** tu dispositivo o simulador
4. **Ejecuta** el proyecto (⌘+R)

### Permisos Requeridos
La aplicación solicitará permisos para:
- **Cámara**: Para tomar fotos de recibos
- **Galería de fotos**: Para seleccionar imágenes existentes

## 🔮 Funcionalidades Futuras

- [ ] Sincronización con iCloud
- [ ] Notificaciones push para recordatorios
- [ ] Exportación de datos (PDF, CSV)
- [ ] Categorías personalizadas
- [ ] Gastos recurrentes
- [ ] Múltiples monedas
- [ ] Dark mode
- [ ] Widgets para iOS
- [ ] Apple Watch companion app
- [ ] Integración con bancos (Open Banking)

## 🤝 Contribución

Este proyecto está diseñado como una aplicación completa y funcional para iOS. Las contribuciones son bienvenidas:

1. Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit de tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Si encuentras algún problema o tienes sugerencias, por favor abre un issue en el repositorio.

---

**Versión**: 1.0  
**Desarrollado con**: ❤️ y Swift  
**Compatibilidad**: iOS 16.0+
