# Oracle APEX Setup & Benchmark Metrics (`./metrics`)

Selles kataloogis säilitatakse ja jälgitakse Git-is paigalduse etappide ja ajakulu mõõtmistulemusi (benchmarks).

Neid andmeid saab kasutada:
1. Kasutajale paigalduse edenemise (Progress Bar / ETA) kuvamiseks.
2. Eri keskkondade ja riistvara jõudluse võrdlemiseks.

## Failid

- `setup_benchmarks.json` - Viimase paigalduse etappide ajakulu sekundites (JSON formaadis)
- `setup_benchmarks.env` - Ajakulu parameetrid keskkonnamuutujatena

*(Märkus: Täielikud paigalduse silumislogid salvestatakse ainult lokaalselt kausta `install_logs/` ega lähe Git-i).*
