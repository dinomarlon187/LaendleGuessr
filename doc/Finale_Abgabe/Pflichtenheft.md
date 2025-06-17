# Pflichtenheft

## 1 Softwarevorraussetzungen

- Flutter:
    - sdk: flutter
- Packages:
    - flutter_staggered_animations: ^1.1.1
    - cupertino_icons: ^1.0.8
    - shared_preferences: ^2.5.3
    - permission_handler: ^11.0.0
    - flutter_map: ^6.2.1
    - latlong2: ^0.9.0
    - geolocator: ^10.1.0
    - flutter_native_splash: ^2.4.0
    - provider: ^6.1.3
    - pedometer: ^4.0.0
    - http: ^1.2.1

## 2 Architektur

### 2.1 Klassen

#### 2.1.1 Datenklassen (Schemes)

- Account (abstrakt)
  - Admin
  - User
- City (enum)
  - CityExtension
- Item
- Quest

#### 2.1.2 Manager

- Inventory (quasi ItemManager)
- QuestManager
- UserManager

#### 2.1.3 Controller

- AppController

#### 2.1.4 Klassenhierarchie

##### 2.1.4.1 Beschreibung

Wir haben uns für folgende Hierarchie entschieden:

- Services, welche von mehreren Stellen im Programm erreichbar sind/benutzt werden
- Datenklassen, welche nur Schemen darstellen und quasi nichts können
- Manager, welche diese Datenklassen verwalten und ihnen die Funktionalität bieten
- Controller (AppController), welcher die Manager verwaltet 

#### 2.1.4.2 Visualisierung im Klassendiagramm

```uml
@startuml
set namespaceSeparator ::

class "laendle_guessr::controller::appcontroller.dart::AppController" {
  {static} -AppController _instance
  +LocationChecker locationChecker
  +QuestManager questManager
  +UserManager userManager
  {static} +AppController instance
}

"laendle_guessr::controller::appcontroller.dart::AppController" o-- "laendle_guessr::controller::appcontroller.dart::AppController"
"laendle_guessr::controller::appcontroller.dart::AppController" o-- "laendle_guessr::services::locationchecker.dart::LocationChecker"
"laendle_guessr::controller::appcontroller.dart::AppController" o-- "laendle_guessr::manager::questmanager.dart::QuestManager"
"laendle_guessr::controller::appcontroller.dart::AppController" o-- "laendle_guessr::manager::usermanager.dart::UserManager"

abstract class "laendle_guessr::data_objects::account.dart::Account" {
  +int uid
  +String username
  +bool isAdmin
  +String password
}

class "laendle_guessr::data_objects::admin.dart::Admin" {
}

"laendle_guessr::data_objects::account.dart::Account" <|-- "laendle_guessr::data_objects::admin.dart::Admin"

class "laendle_guessr::data_objects::city.dart::City" {
  +int index
  {static} +List<City> values
  {static} +City bregenz
  {static} +City dornbirn
  {static} +City hohenems
  {static} +City feldkirch
  {static} +City bludenz
}

"laendle_guessr::data_objects::city.dart::City" o-- "laendle_guessr::data_objects::city.dart::City"
"dart::core::Enum" <|-- "laendle_guessr::data_objects::city.dart::City"

class "laendle_guessr::data_objects::item.dart::Item" {
  +int id
  +String image
  +String name
  +int price
}

class "laendle_guessr::data_objects::quest.dart::Quest" {
  +int qid
  +String image
  +City city
  +double latitude
  +double longitude
}

"laendle_guessr::data_objects::quest.dart::Quest" o-- "laendle_guessr::data_objects::city.dart::City"

class "laendle_guessr::data_objects::user.dart::User" {
  +int coins
  +Inventory inventory
  +City city
  +Quest? activeQuest
}

"laendle_guessr::data_objects::user.dart::User" o-- "laendle_guessr::manager::inventory.dart::Inventory"
"laendle_guessr::data_objects::user.dart::User" o-- "laendle_guessr::data_objects::city.dart::City"
"laendle_guessr::data_objects::user.dart::User" o-- "laendle_guessr::data_objects::quest.dart::Quest"
"laendle_guessr::data_objects::account.dart::Account" <|-- "laendle_guessr::data_objects::user.dart::User"

class "laendle_guessr::login.dart::LoginPage" {
  +State<LoginPage> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::login.dart::LoginPage"

class "laendle_guessr::login.dart::_LoginPageState" {
  -TextEditingController _usernameController
  -TextEditingController _passwordController
  -void _handleLogin()
  +Widget build()
}

"laendle_guessr::login.dart::_LoginPageState" o-- "flutter::src::widgets::editable_text.dart::TextEditingController"   
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::login.dart::_LoginPageState"

class "laendle_guessr::main.dart::LaendleGuessrApp" {
  +Widget build()
}

"flutter::src::widgets::framework.dart::StatelessWidget" <|-- "laendle_guessr::main.dart::LaendleGuessrApp"

class "laendle_guessr::main.dart::HomePage" {
  +State<HomePage> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::main.dart::HomePage"

class "laendle_guessr::main.dart::_HomePageState" {
  -int _selectedIndex
  -List<Widget> _pages
  +void initState()
  -void _navigateToMaps()
  +Widget build()
}

"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::main.dart::_HomePageState"

class "laendle_guessr::main.dart::HomeContent" {
  +void Function() onNavigateToMaps
  +State<HomeContent> createState()
}

"laendle_guessr::main.dart::HomeContent" o-- "dart::ui::void Function()"
"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::main.dart::HomeContent"

class "laendle_guessr::main.dart::_HomeContentState" {
  -int? _activeQid
  +void initState()
  -void _onStartQuest()
  +Widget build()
}

"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::main.dart::_HomeContentState"

class "laendle_guessr::main.dart::ChallengeCard" {
  +String title
  +String imageUrl
  +String question
  +String description
  +String buttonText
  +Color color
  +int qid
  +bool isThisQuestActive
  +bool isAnyQuestActive
  +void Function() onPressed
  +Widget build()
}

"laendle_guessr::main.dart::ChallengeCard" o-- "dart::ui::Color"
"laendle_guessr::main.dart::ChallengeCard" o-- "dart::ui::void Function()"
"flutter::src::widgets::framework.dart::StatelessWidget" <|-- "laendle_guessr::main.dart::ChallengeCard"

class "laendle_guessr::manager::inventory.dart::Inventory" {
  +List<Item> items
  +ItemService itemService
  +void addItemToInventory()
  +dynamic getAllItemsFromUser()
  +dynamic getItemById()
  +dynamic getAllItems()
}

"laendle_guessr::manager::inventory.dart::Inventory" o-- "laendle_guessr::services::item_service.dart::ItemService"    

class "laendle_guessr::manager::questmanager.dart::QuestManager" {
  {static} -QuestManager _instance
  +UserManager userManager
  +Quest weeklyQuest
  +Map<City, Quest> dailyQuestByCity
  -Timer? _midnightTimer
  -Duration? _timeUntilMidnight
  +ValueNotifier<Duration> timeUntilMidnightNotifier
  +QuestService questService
  +Timer? questTimer
  +int elapsedSeconds
  {static} +QuestManager instance
  +String elapsedTime
  +bool isRunning
  +dynamic loadQuests()
  -void _scheduleMidnightUpdate()
  +void dispose()
  +Quest? getDailyQuestForUser()
  +Quest getWeeklyQuest()
  +dynamic getAllQuests()
  +dynamic getAllDoneQuestsByUser()
  +dynamic fetchActiveQuest()
  +dynamic startQuest()
  +dynamic startTracking()
  +void startQuestTimer()
  +void forfeitQuest()
  +void finishQuest()
}

"laendle_guessr::manager::questmanager.dart::QuestManager" o-- "laendle_guessr::manager::questmanager.dart::QuestManager"
"laendle_guessr::manager::questmanager.dart::QuestManager" o-- "laendle_guessr::manager::usermanager.dart::UserManager"
"laendle_guessr::manager::questmanager.dart::QuestManager" o-- "laendle_guessr::data_objects::quest.dart::Quest"       
"laendle_guessr::manager::questmanager.dart::QuestManager" o-- "dart::async::Timer"
"laendle_guessr::manager::questmanager.dart::QuestManager" o-- "flutter::src::foundation::change_notifier.dart::ValueNotifier<Duration>"
"laendle_guessr::manager::questmanager.dart::QuestManager" o-- "laendle_guessr::services::quest_service.dart::QuestService"
"flutter::src::foundation::change_notifier.dart::ChangeNotifier" <|-- "laendle_guessr::manager::questmanager.dart::QuestManager"

class "laendle_guessr::manager::usermanager.dart::UserManager" {
  {static} -UserManager _instance
  +ApiService apiService
  +User? currentUser
  {static} +UserManager instance
  +dynamic loginUser()
  +dynamic login()
  +void logoutUser()
  +void completeQuest()
  +dynamic buyItem()
  +bool ownsItem()
}

"laendle_guessr::manager::usermanager.dart::UserManager" o-- "laendle_guessr::manager::usermanager.dart::UserManager"  
"laendle_guessr::manager::usermanager.dart::UserManager" o-- "laendle_guessr::services::api_service.dart::ApiService"  
"laendle_guessr::manager::usermanager.dart::UserManager" o-- "laendle_guessr::data_objects::user.dart::User"
"flutter::src::foundation::change_notifier.dart::ChangeNotifier" <|-- "laendle_guessr::manager::usermanager.dart::UserManager"

class "laendle_guessr::maps.dart::MapsPage" {
  +State<MapsPage> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::maps.dart::MapsPage"

class "laendle_guessr::maps.dart::_MapsPageState" {
  -LatLng? _currentLocation
  -MapController _mapController
  -StreamSubscription<Position>? _positionStreamSubscription
  -UserManager _userManager
  +LocationChecker locationChecker
  -QuestManager _questManager
  -double _currentZoom
  -bool _isMapReady
  -bool _isButtonPressed
  +bool wantKeepAlive
  +void initState()
  -dynamic _checkPermissionsAndStartTracking()
  -void _showError()
  +void dispose()
  +Widget build()
  -Widget _buildActiveQuestBar()
  -Widget _buildInfoBox()
  -Widget _buildInactiveQuestBar()
}

"laendle_guessr::maps.dart::_MapsPageState" o-- "latlong2::latlong.dart::LatLng"
"laendle_guessr::maps.dart::_MapsPageState" o-- "flutter_map::src::map::controller::map_controller.dart::MapController"
"laendle_guessr::maps.dart::_MapsPageState" o-- "dart::async::StreamSubscription<Position>"
"laendle_guessr::maps.dart::_MapsPageState" o-- "laendle_guessr::manager::usermanager.dart::UserManager"
"laendle_guessr::maps.dart::_MapsPageState" o-- "laendle_guessr::services::locationchecker.dart::LocationChecker"      
"laendle_guessr::maps.dart::_MapsPageState" o-- "laendle_guessr::manager::questmanager.dart::QuestManager"
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::maps.dart::_MapsPageState"
"flutter::src::widgets::automatic_keep_alive.dart::AutomaticKeepAliveClientMixin" <|-- "laendle_guessr::maps.dart::_MapsPageState"

class "laendle_guessr::profile.dart::ProfilePage" {
  +State<ProfilePage> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::profile.dart::ProfilePage"

class "laendle_guessr::profile.dart::_ProfilePageState" {
  +User user
  -AnimationController _animationController
  -Animation<double> _fadeAnimation
  -Animation<Offset> _slideAnimation
  +void initState()
  +void dispose()
  +Widget build()
  -Widget _buildStatCard()
}

"laendle_guessr::profile.dart::_ProfilePageState" o-- "laendle_guessr::data_objects::user.dart::User"
"laendle_guessr::profile.dart::_ProfilePageState" o-- "flutter::src::animation::animation_controller.dart::AnimationController"
"laendle_guessr::profile.dart::_ProfilePageState" o-- "flutter::src::animation::animation.dart::Animation<double>"     
"laendle_guessr::profile.dart::_ProfilePageState" o-- "flutter::src::animation::animation.dart::Animation<Offset>"     
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::profile.dart::_ProfilePageState"
"flutter::src::widgets::ticker_provider.dart::SingleTickerProviderStateMixin" <|-- "laendle_guessr::profile.dart::_ProfilePageState"

class "laendle_guessr::services::api_service.dart::ApiService" {
  {static} -ApiService _instance
  +String baseURL
  {static} +ApiService instance
  +dynamic get()
  +dynamic post()
  +dynamic put()
  +dynamic delete()
}

"laendle_guessr::services::api_service.dart::ApiService" o-- "laendle_guessr::services::api_service.dart::ApiService"  

class "laendle_guessr::services::item_service.dart::ItemService" {
  {static} -ItemService _instance
  +ApiService api
  {static} +ItemService instance
  +dynamic getAllItems()
  +dynamic getAllItemsByUser()
  +dynamic getItemById()
  +dynamic addItemToInventory()
}

"laendle_guessr::services::item_service.dart::ItemService" o-- "laendle_guessr::services::item_service.dart::ItemService"
"laendle_guessr::services::item_service.dart::ItemService" o-- "laendle_guessr::services::api_service.dart::ApiService"

class "laendle_guessr::services::locationchecker.dart::LocationChecker" {
  {static} -LocationChecker _instance
  -StreamSubscription<Position>? _positionStream
  +UserManager userManager
  -LocationSettings _locationSettings
  {static} +LocationChecker instance
  +dynamic checkPermission()
  +dynamic startListening()
  +void stopListening()
  +dynamic checkLocation()
}

"laendle_guessr::services::locationchecker.dart::LocationChecker" o-- "laendle_guessr::services::locationchecker.dart::LocationChecker"
"laendle_guessr::services::locationchecker.dart::LocationChecker" o-- "dart::async::StreamSubscription<Position>"      
"laendle_guessr::services::locationchecker.dart::LocationChecker" o-- "laendle_guessr::manager::usermanager.dart::UserManager"
"laendle_guessr::services::locationchecker.dart::LocationChecker" o-- "geolocator_platform_interface::src::models::location_settings.dart::LocationSettings"

class "laendle_guessr::services::quest_service.dart::QuestService" {
  {static} -QuestService _instance
  +ApiService api
  {static} +QuestService instance
  +dynamic getAllQuests()
  +dynamic getAllDoneQuestsByUser()
  +dynamic getdailyQuest()
  +dynamic getweeklyQuest()
  +dynamic postQuestDoneByUser()
  +dynamic getActiveQuestForUser()
  +dynamic getQuestById()
  +dynamic addQuestToActive()
  +dynamic removeQuestFromActive()
  +dynamic getActiveQuestDuration()
  +dynamic updateActiveQuestStepCount()
  +dynamic getActiveQuestStepCount()
}

"laendle_guessr::services::quest_service.dart::QuestService" o-- "laendle_guessr::services::quest_service.dart::QuestService"
"laendle_guessr::services::quest_service.dart::QuestService" o-- "laendle_guessr::services::api_service.dart::ApiService"

class "laendle_guessr::services::step_counter.dart::StepCounter" {
  {static} -StepCounter _instance
  -Stream<StepCount> _stepCountStream
  -StreamSubscription<StepCount>? _stepCountSubscription
  -int _totalSteps
  -int _initialPedometerValue
  -int _dbStepCount
  {static} -String _pedometerValueKey
  {static} +StepCounter instance
  +int totalSteps
  +void onStepCount()
  +void onStepCountError()
  +dynamic startStepCounting()
  +dynamic stopStepCounting()
  -dynamic _saveInitialPedometerValue()
  -dynamic _loadInitialPedometerValue()
  -dynamic _clearInitialPedometerValue()
}

"laendle_guessr::services::step_counter.dart::StepCounter" o-- "laendle_guessr::services::step_counter.dart::StepCounter"
"laendle_guessr::services::step_counter.dart::StepCounter" o-- "dart::async::Stream<StepCount>"
"laendle_guessr::services::step_counter.dart::StepCounter" o-- "dart::async::StreamSubscription<StepCount>"
"flutter::src::foundation::change_notifier.dart::ChangeNotifier" <|-- "laendle_guessr::services::step_counter.dart::StepCounter"

class "laendle_guessr::services::user_service.dart::UserService" {
  +ApiService api
  {static} -UserService _instance
  {static} +UserService instance
  +dynamic getAllUsers()
  +dynamic checkCredentials()
  +dynamic getUser()
  +dynamic registerUser()
  +dynamic updateUser()
}

"laendle_guessr::services::user_service.dart::UserService" o-- "laendle_guessr::services::api_service.dart::ApiService"
"laendle_guessr::services::user_service.dart::UserService" o-- "laendle_guessr::services::user_service.dart::UserService"

class "laendle_guessr::shop.dart::ShopPage" {
  +State<ShopPage> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::shop.dart::ShopPage"

class "laendle_guessr::shop.dart::_ShopPageState" {
  +dynamic futureItems
  -UserManager _userManager
  +void initState()
  +void dispose()
  -void _onUserDataChanged()
  +Widget build()
}

"laendle_guessr::shop.dart::_ShopPageState" o-- "laendle_guessr::manager::usermanager.dart::UserManager"
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::shop.dart::_ShopPageState"

class "laendle_guessr::signup.dart::SignupPage" {
  +State<SignupPage> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::signup.dart::SignupPage"

class "laendle_guessr::signup.dart::_SignupPageState" {
  -GlobalKey<FormState> _formKey
  -TextEditingController _usernameController
  -TextEditingController _passwordController
  -String? _selectedCity
  -bool _isLoading
  -List<String> _cities
  -int _getCityId()
  -void _submit()
  +Widget build()
}

"laendle_guessr::signup.dart::_SignupPageState" o-- "flutter::src::widgets::framework.dart::GlobalKey<FormState>"      
"laendle_guessr::signup.dart::_SignupPageState" o-- "flutter::src::widgets::editable_text.dart::TextEditingController" 
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::signup.dart::_SignupPageState"

class "laendle_guessr::ui::ItemCard.dart::ItemCard" {
  +Item item
  +void Function()? onPurchaseSuccess
  +Widget build()
}

"laendle_guessr::ui::ItemCard.dart::ItemCard" o-- "laendle_guessr::data_objects::item.dart::Item"
"laendle_guessr::ui::ItemCard.dart::ItemCard" o-- "dart::ui::void Function()"
"flutter::src::widgets::framework.dart::StatelessWidget" <|-- "laendle_guessr::ui::ItemCard.dart::ItemCard"

class "laendle_guessr::ui::test.dart::LocationScreen" {
  +_LocationScreenState createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::ui::test.dart::LocationScreen"

class "laendle_guessr::ui::test.dart::_LocationScreenState" {
  -String _locationText
  -LocationChecker _locationChecker
  +void initState()
  +void dispose()
  +Widget build()
}

"laendle_guessr::ui::test.dart::_LocationScreenState" o-- "laendle_guessr::services::locationchecker.dart::LocationChecker"
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::ui::test.dart::_LocationScreenState"

class "laendle_guessr::willkommen.dart::WelcomeScreen" {
  +State<WelcomeScreen> createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "laendle_guessr::willkommen.dart::WelcomeScreen"

class "laendle_guessr::willkommen.dart::_WelcomeScreenState" {
  -AnimationController _controller
  -Animation<double> _fadeIn
  +void initState()
  +void dispose()
  -void _goToHome()
  +Widget build()
}

"laendle_guessr::willkommen.dart::_WelcomeScreenState" o-- "flutter::src::animation::animation_controller.dart::AnimationController"
"laendle_guessr::willkommen.dart::_WelcomeScreenState" o-- "flutter::src::animation::animation.dart::Animation<double>"
"flutter::src::widgets::framework.dart::State" <|-- "laendle_guessr::willkommen.dart::_WelcomeScreenState"
"flutter::src::widgets::ticker_provider.dart::SingleTickerProviderStateMixin" <|-- "laendle_guessr::willkommen.dart::_WelcomeScreenState"


@enduml
```



### 2.2 Aufbau der UI

- Ein MainWindow, welches immer angezeigt wird. Über dieses werden dann die jeweiligen Pages angezeigt.

- MainWindow:
    - Window, mit einem Menü um die einzelnen Pages anzeigen zu lassen, ist dauerhaft ersichtlich
- WindowAddQuestion:
    - Window, um Fragen zu erstellen/editieren
- PageHome:
    - Page, Titelseite, auf welcher der User eine kurze Beschreibung bekommt, was er tun kann/soll
- PageAufgabe:
    - Page, um die Aufgaben anzuzeigen und zu beantworten
- PageEnglisch:
    - Page, auf welcher der  user Vokabeln üben/anzeigen/manipulieren kann
- PageLogin:
    - Page, wenn der User sich einloggen will
- PageSign:
    - Page, wenn der User sich registrieren will
- PageNewQuestion: 
    - Page, um die derzeitige Fragenliste des Users anzuzeigen und zu manipulieren (Fragen hinzufügen, editieren, löschen)
- PageEinstellungen:
    - Page, auf welcher der User sein Profil anpassen kann und auch das Theme (Darkmode/Lightmode) ändern kann
- PageProfile:
    - Page, auf welcher der user sein Profil und seine Statistiken einsehen kann
    


## 3 Umsetzung der Anforderungen

### 3.1 Organisatorisch

- zweier Gruppe: Bilal Ensar Bugday, Marlon Pichler
- Arbeit im Unterricht und zubhause (siehe GIT-Repository)

### 3.2 Technischer Inhalt

#### 3.2.1 Must Haves

- Klassen:
    - Wir haben Klassen verwendet (siehe Punkt 2.1 für weitere Informationen)
- Collections:
    - Wir haben in vielen Klassen/Funktionen mit Listen/Arrays gearbeitet.
    - Wir haben das JSON-Format für das Speichern von Daten verwendet. Dies basiert auf Dictionaries.
- Graphische Darstellung von Objekten:
    - Wir haben, um unser Programm so intuitiv und effizient wie möglich zu gestalten, in verschiedensten Pages/Windows Objekte graphisch dargestellt.
- Serialisierung:
    - Wir haben unsere Daten lokal im JSON-Format abgespeichert.
    - Dadurch konnten wir:
        - den Usern das permanente Verändern ihres Benutzernamen oder des Profilbildes ermöglichen
        - den Usern das Erstellen ihrer eigenen, individuellen Frageliste und Vokabelliste ermöglichen
- Unterformulare:
    - Durch unsere permanente *Verwendung von Unterformularen und Pageswitches* konnten wir den Usern die intuitivste und bedienungsleichteste Benutzeroberfläche bieten.
- Logging:
    - Wir haben unser Projekt so effizient und zielorientiert wie möglich geloggt um eine gute Debug-Möglichkeit und Problembehandlung zu sichern
    - Dabei haben wir unseren Logger so designed, dass dieser täglich neue Logging-Dateien erstellt, diese an diesem Tag befüllt und nach sieben Tagen wieder löscht.

#### 3.2.2 Nice To Haves

- Menüzeile:
    - Wir haben aufgrund der Intuitivität in unserer Anwendung eine selbstprogrammierte Menüspalte, welche immer sichtbar ist und auf welcher man einfach zwischen den Pager navigieren kann
- Verwendung von externen Bibliotheken:
    - Wir haben in unserem Programm (siehe Punkt 1) sowohl für das Loggen, als auch für die Serialisierung NuGet Packages verwendet.
    - Dies hat uns sehr weitergeholfen, da wir nun nicht selbst die Serialisierung in das JSON-Format übernehmen mussten
- Vererbung:
    - Um unsere Klassenstruktur (siehe Punkt 2.1) so effizient wie möglich zu gestalten, haben wir die "Vererbung von Klassen" gelernt/benutzt.
    - Dies hat uns massiv weitergeholfen, da wir dadurch alle unsere Fragen in eine große Fragenliste speichern konnten. Ohne Vererbung wäre das ganze Projekt sehr viel komplexer und unübersichtlicher geworden

### 3.3 Beschreibung der Anwendung

Erstmal haben wir ein "MainWindow", welche das Grundkonstrukt unserer Anwendung bildet. Auf dieser ist eine "Menüspalte", über welche man in der gesamten Anwendung navigieren kann.
Auf diesem "MainWindow" werden dann die einzelnen Pages geladen. Man startet immer auf der PageHome, auf welcher man aufgefordert wird, sich anzumelden oder sich zu registrieren.
Wenn versucht wird zu diesem Zeitpunkt eine andere Page zu öffnen, bekommt man eine Mitteilung, dass man sich anmelden/registrieren muss. Bei einem Klick auf "Anmelden"/"Registrieren"
wird man auf die jeweilige Page weitergeleitet und kann sich anmelden/registrieren.

Sobald man dies getan hat, stehen einem alle Wege offen. Man kann mit nur einem einzigen Klick in der Menüspalte seine Fähigkeiten in Deutsch/Mathe durch Fragen von verschiedenen Fragetypen verbessern, seine Englischkentnisse mit Vokabeln verbessern, 
seine Fragenliste anpassen, sein Benutzerkonto verändern, seine Statistiken einsehen,...

## 4 Mögliche Probleme und ihre Lösung

- Natürlich hat bei unserem Projekt nicht alles auf Anhieb geklappt und wir hatten allfällige Schwierigkeiten. Spezifische Beispiele und deren Lösungen werden hier näher besprochen 

### 4.1 Serialisierung - Einheitliches Laden/Speichern von Fragen

- Speziell bei der Serialisierung hatten wir eine recht große Schwierigkeit, welche uns einige Gehirnzellen und Arbeitszeit abverlangt hat.
- Wir konnten zwar recht schnell Fragen Laden, jedoch wurde es beim Speichern um einiges schwerer:
    - Wir konnten die Fragen zwar einmal Deserialisieren, jedoch nach dem Serialisieren nicht mehr Deserialisieren
    - Dies lag daran, dass unser Serialisierter Text einen andere Struktur benutzte, welche wir nicht deserialisieren konnten
    - Lösung:
        - Man kann dem Serializer von Newtonsoft.Json, welchen wir verwendet haben, genau sagen, was er von einem Objekt serialisieren soll und was nicht
        
### 4.2 Userspezifische Fragedateien

- Anfangs hatten wir eine Frageliste, welche dann bearbeitet werden konnte. 
- Das Problem:
    - Jeder User bearbeitet dieselbe Frageliste.
- Die Lösung:
    - Beim erstellen/registrieren eines Benutzers wird automatisch eine eigene JSON-Datei erstellt, welche anfangs die originale Frageliste enthält.
    - Zudem wird der derzeit angemeldete User als statische Variable gespeichert
        - Dadurch kann die Frageliste des Users und die dazugehörige Datei angepasst werden, ohne die anderen Fragedateien der anderen User zu manipulieren
        - Zudem kann auch jederzeit der Dateipfad bzw. der Dateiname, in welchem die Fragen des Benutzers liegen, verändert werden, falls der Username geändert wird
        