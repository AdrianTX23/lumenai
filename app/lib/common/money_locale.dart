/// The locale governing money formatting across the app.
///
/// LUMEN AI is built for the Colombian market: peso amounts group with
/// dots, carry no decimals and lead with the symbol (`$ 4.200.000`)
/// regardless of the UI language the user picks. Deliberately a constant,
/// not derived from the device locale — amounts must look the same in
/// every screenshot, test and demo.
const appMoneyLocale = 'es_CO';
