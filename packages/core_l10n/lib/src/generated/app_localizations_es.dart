import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LUMEN AI';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabActivity => 'Actividad';

  @override
  String get tabInsights => 'Análisis';

  @override
  String get tabCopilot => 'Copiloto';

  @override
  String get homeNetWorth => 'Patrimonio';

  @override
  String get homeAccounts => 'Cuentas';

  @override
  String get homeRecentActivity => 'Actividad reciente';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeSettings => 'Ajustes';

  @override
  String get homeNoAccountsTitle => 'Aún no tienes cuentas';

  @override
  String get homeNoAccountsMessage =>
      'Agrega una cuenta para empezar a registrar tu dinero.';

  @override
  String get homeAddAccount => 'Agregar cuenta';

  @override
  String get activityTitle => 'Actividad';

  @override
  String get activitySearchHint => 'Busca comercios o notas';

  @override
  String get activityFilterAll => 'Todas';

  @override
  String get activityEmptyTitle => 'Sin resultados';

  @override
  String get activityEmptyMessage => 'Prueba otra búsqueda u otro filtro.';

  @override
  String get activityAdd => 'Agregar transacción';

  @override
  String get activityAddTitle => 'Nueva transacción';

  @override
  String get activityAmountLabel => 'Monto';

  @override
  String get activityMerchantLabel => 'Comercio o descripción';

  @override
  String get activityMerchantHint => 'p. ej. Éxito, Uber, Nómina';

  @override
  String get activityAccountLabel => 'Cuenta';

  @override
  String get activityDateLabel => 'Fecha';

  @override
  String get activityNoteLabel => 'Nota (opcional)';

  @override
  String get activitySpend => 'Gasto';

  @override
  String get activityIncome => 'Ingreso';

  @override
  String get activitySave => 'Guardar transacción';

  @override
  String get activityCreated => 'Transacción guardada';

  @override
  String get activityCreateFailed => 'No se pudo guardar la transacción';

  @override
  String get activityInvalidAmount => 'Ingresa un monto mayor a cero';

  @override
  String get activitySelectAccount => 'Elige una cuenta';

  @override
  String get activityNoAccountsYet => 'Primero agrega una cuenta';

  @override
  String get activityDelete => 'Eliminar transacción';

  @override
  String get activityDeleted => 'Transacción eliminada';

  @override
  String get activityDeleteFailed => 'No se pudo eliminar la transacción';

  @override
  String get activityDeleteConfirmTitle => '¿Eliminar esta transacción?';

  @override
  String get activityDeleteConfirmBody => 'Esta acción no se puede deshacer.';

  @override
  String get detailCategory => 'Categoría';

  @override
  String get detailAccount => 'Cuenta';

  @override
  String get detailDate => 'Fecha';

  @override
  String get detailNote => 'Nota';

  @override
  String get detailRecategorize => 'Cambiar categoría';

  @override
  String get snackRecategorized => 'Categoría actualizada';

  @override
  String get snackRecategorizeFailed => 'No se pudo actualizar la categoría';

  @override
  String get errorTitle => 'Algo ha ido mal';

  @override
  String get errorMessage => 'No hemos podido cargar tus datos.';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String get insightsTitle => 'Análisis';

  @override
  String get insightsThisMonth => 'Este mes';

  @override
  String get insightsSpendingByCategory => 'Gasto por categoría';

  @override
  String get insightsEmptyBreakdown => 'Sin gastos este mes todavía';

  @override
  String get insightsCashflowTitle => 'Ingresos vs. gasto';

  @override
  String get insightsIncome => 'Ingresos';

  @override
  String get insightsSpend => 'Gasto';

  @override
  String get insightsSubscriptionsTitle => 'Cargos recurrentes';

  @override
  String get insightsSubscriptionsEmpty =>
      'Aún no se detectan cargos recurrentes';

  @override
  String get insightsForecastTitle => 'Próximo mes';

  @override
  String get insightsForecastCaption =>
      'Gasto proyectado según tus meses recientes';

  @override
  String get budgetsTitle => 'Presupuestos';

  @override
  String get budgetsEmptyTitle => 'Sin presupuestos todavía';

  @override
  String get budgetsEmptyMessage =>
      'Define un límite mensual por categoría para seguir tu ritmo de gasto.';

  @override
  String get budgetsAdd => 'Añadir presupuesto';

  @override
  String get budgetsNewTitle => 'Nuevo presupuesto';

  @override
  String get budgetsCategory => 'Categoría';

  @override
  String get budgetsLimit => 'Límite mensual';

  @override
  String get budgetsLimitHint => '0';

  @override
  String get budgetsSave => 'Guardar presupuesto';

  @override
  String get budgetsDelete => 'Eliminar';

  @override
  String get budgetsOverBudget => 'Presupuesto superado';

  @override
  String get budgetsNearLimit => 'Cerca del límite';

  @override
  String get budgetsCreated => 'Presupuesto guardado';

  @override
  String get budgetsCreateFailed => 'No se pudo guardar el presupuesto';

  @override
  String get budgetsDeleted => 'Presupuesto eliminado';

  @override
  String get budgetsInvalidLimit => 'Ingresa un monto mayor a cero';

  @override
  String get budgetsSelectCategory => 'Elige una categoría';

  @override
  String get copilotInputHint => 'Pregunta sobre tu dinero';

  @override
  String get copilotSendLabel => 'Enviar';

  @override
  String get copilotWelcomeTitle => 'Pregúntale a Lumen';

  @override
  String get copilotWelcomeMessage =>
      'Puedo ayudarte a entender tus gastos — prueba con esto.';

  @override
  String get copilotSuggestionDining =>
      '¿Cuánto gasté en restaurantes este mes?';

  @override
  String get copilotSuggestionSubscriptions =>
      '¿Alguna suscripción que deba revisar?';

  @override
  String get copilotSuggestionForecast =>
      '¿Cuál es mi pronóstico para el próximo mes?';

  @override
  String get copilotSourceSingular => 'fuente';

  @override
  String get copilotSourcePlural => 'fuentes';

  @override
  String get copilotEvidenceSheetTitle => 'Transacciones citadas';

  @override
  String get categoryGroceries => 'Supermercado';

  @override
  String get categoryDining => 'Restaurantes';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categorySubscriptions => 'Suscripciones';

  @override
  String get categoryHousing => 'Vivienda';

  @override
  String get categoryUtilities => 'Suministros';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryTravel => 'Viajes';

  @override
  String get categoryEntertainment => 'Ocio';

  @override
  String get categoryIncome => 'Ingresos';

  @override
  String get categoryTransfers => 'Transferencias';

  @override
  String get categoryFees => 'Comisiones';

  @override
  String get categoryOther => 'Otros';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingPage1Title => 'Todo tu dinero, en una sola vista';

  @override
  String get onboardingPage1Body =>
      'Cuentas, tarjetas y gastos juntos — sin cambiar entre aplicaciones.';

  @override
  String get onboardingPage2Title => 'Análisis que realmente ayudan';

  @override
  String get onboardingPage2Body =>
      'Tendencias de gasto, cargos recurrentes y un pronóstico para el próximo mes, de forma automática.';

  @override
  String get onboardingPage3Title => 'Pregúntale lo que sea a Lumen';

  @override
  String get onboardingPage3Body =>
      'Un copiloto conversacional basado en tus transacciones reales — cada respuesta es rastreable.';

  @override
  String get onboardingSecurityTitle => 'Protege tu app';

  @override
  String get onboardingSecurityBody =>
      'Activa el bloqueo biométrico para mantener tus finanzas privadas, incluso si alguien más toma tu teléfono.';

  @override
  String get onboardingEnableBiometrics => 'Activar Face ID / huella';

  @override
  String get onboardingBiometricReason =>
      'Confirma tu identidad para proteger LUMEN AI';

  @override
  String get onboardingBiometricUnavailable =>
      'La biometría no está disponible en este dispositivo';

  @override
  String get lockTitle => 'LUMEN AI está bloqueada';

  @override
  String get lockSubtitle => 'Usa Face ID o tu huella para continuar';

  @override
  String get lockUnlockButton => 'Desbloquear';

  @override
  String get lockReason => 'Confirma tu identidad para abrir LUMEN AI';

  @override
  String get lockFailed =>
      'No pudimos verificar tu identidad — intenta de nuevo';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAppearanceCaption =>
      'Sigue el modo claro/oscuro de tu sistema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsBiometricLock => 'Bloqueo biométrico';

  @override
  String get settingsBiometricUnavailable =>
      'Este dispositivo no tiene biometría disponible';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsResetData => 'Restablecer datos de demo';

  @override
  String get settingsResetConfirmTitle => '¿Restablecer todos los datos?';

  @override
  String get settingsResetConfirmBody =>
      'Esto borra y vuelve a generar el conjunto de datos de demostración. No se puede deshacer.';

  @override
  String get settingsResetConfirmAction => 'Restablecer';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String get settingsResetSuccess => 'Datos restablecidos';

  @override
  String get settingsResetFailed => 'No se pudieron restablecer los datos';

  @override
  String get settingsAccounts => 'Cuentas';

  @override
  String get accountTypeChecking => 'Cuenta corriente';

  @override
  String get accountTypeSavings => 'Ahorros';

  @override
  String get accountTypeCredit => 'Tarjeta de crédito';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountsAddTitle => 'Nueva cuenta';

  @override
  String get accountsNameLabel => 'Nombre';

  @override
  String get accountsNameHint => 'p. ej. Bancolombia Ahorros';

  @override
  String get accountsTypeLabel => 'Tipo';

  @override
  String get accountsOpeningBalanceLabel => 'Saldo inicial';

  @override
  String get accountsSave => 'Guardar cuenta';

  @override
  String get accountsCreated => 'Cuenta creada';

  @override
  String get accountsCreateFailed => 'No se pudo crear la cuenta';

  @override
  String get accountsInvalidName => 'Ingresa un nombre';

  @override
  String get accountsSelectType => 'Elige un tipo de cuenta';
}
