import { StatusBar } from 'expo-status-bar';
import { useTranslation } from 'react-i18next';
import { Button, StyleSheet, Text, View } from 'react-native';

import './src/i18n';

type Props = { name: string; count: number; total: string; promoCode: string };

export default function App({ name, count, total, promoCode }: Props) {
  const { t } = useTranslation();
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{t('cart.title').toUpperCase()}</Text>
      <Text>{t('greeting', { name })}</Text>
      <Text>{t('cart.items', { count })}</Text>
      <Text>{t('checkout.total', { amount: total })}</Text>
      <Text>{t(`promo.${promoCode.toLocaleLowerCase()}`)}</Text>
      <Text style={styles.note}>Free shipping on orders over 50 euros</Text>
      <Button title={t('checkout.button')} onPress={() => {}} />
      <Text>{t('checkout.terms')}</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: '600' },
  note: { color: '#555' },
});
