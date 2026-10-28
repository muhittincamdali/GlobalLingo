// i18next set up as in Expo's localization guide: the device language from expo-localization,
// English as the fallback. https://docs.expo.dev/guides/localization/
import { getLocales } from 'expo-localization';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import de from './locales/de.json';
import en from './locales/en.json';
import pl from './locales/pl.json';
import tr from './locales/tr.json';

i18n.use(initReactI18next).init({
  resources: {
    en: { translation: en },
    de: { translation: de },
    pl: { translation: pl },
    tr: { translation: tr },
  },
  lng: getLocales()[0]?.languageCode ?? 'en',
  fallbackLng: 'en',
  interpolation: { escapeValue: false },
});

export default i18n;
