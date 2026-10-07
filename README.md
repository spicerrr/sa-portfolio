<div align="center">

# sa-portfolio

### системный анализ · требования · API · интеграции · данные

[![OpenAPI](https://img.shields.io/badge/OpenAPI_3.0-6BA539?style=flat-square&logo=swagger&logoColor=white)](agritech/contracts/openapi.yaml)
[![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=flat-square&logo=rabbitmq&logoColor=white)](agritech/docs/integration.md)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)](agritech/sql/)
[![BPMN](https://img.shields.io/badge/UML_%2F_BPMN-8250df?style=flat-square)](agritech/diagrams/)

[← профиль](https://github.com/spicerrr) · [кейс](#-интеграционный-кейс) · [артефакты](#-артефакты) · [стек](#-стек)

</div>

---

Здесь лежат не списки технологий, а связанные артефакты системного анализа: **от исходной проблемы и требований до API, модели данных, интеграций и сценариев проверки**.

## 🌱 интеграционный кейс

### движение партии: производство → склад → отчётность

[**открыть кейс целиком →**](agritech/README.md)

> Обезличенная техническая реконструкция на базе коммерческого контекста. Публичные схемы, контракты и примеры не являются внутренней документацией компании.

**Проблема:** несколько источников описывают один объект разными локальными кодами и документами. Связь по названию или дате ненадёжна: появляются дубли, неоднозначные соответствия и расхождения между производственным и складским фактами.

**В кейсе:**
- единый идентификатор сущности и соответствия локальных кодов;
- REST API для регистрации и чтения фактов;
- событийный обмен через RabbitMQ;
- JSON Schema для событий;
- идемпотентность, повторная доставка и DLQ;
- PostgreSQL-модель и SQL;
- UML / BPMN;
- критерии приёмки и Python-проверки согласованности артефактов.

### пример цепочки

```text
проблема
  ↓
бизнес-правило
  ↓
требование
  ↓
API / событие / модель данных
  ↓
сценарий проверки
```

## 📎 артефакты

| Что посмотреть | Ссылка |
|:---|:---|
| Контекст и границы | [docs/context.md](agritech/docs/context.md) |
| Требования | [docs/requirements.md](agritech/docs/requirements.md) |
| Сценарии использования | [docs/use-cases.md](agritech/docs/use-cases.md) |
| OpenAPI 3.0.3 | [contracts/openapi.yaml](agritech/contracts/openapi.yaml) |
| Схема событий | [contracts/events.schema.json](agritech/contracts/events.schema.json) |
| Postman | [contracts/postman.collection.json](agritech/contracts/postman.collection.json) |
| UML / BPMN / ERD | [diagrams/](agritech/diagrams/) |
| PostgreSQL / SQL | [sql/](agritech/sql/) |
| Python-проверки | [scripts/](agritech/scripts/) |
| Критерии приёмки | [docs/acceptance.md](agritech/docs/acceptance.md) |

## 🛠 стек

| Область | Что используется в опубликованном кейсе |
|:---|:---|
| **API** | REST · OpenAPI 3.0.3 · Swagger · Postman · JSON Schema |
| **Интеграции** | RabbitMQ · JSON-события · повторная доставка · DLQ · outbox / inbox |
| **Данные** | PostgreSQL · SQL · ERD |
| **Моделирование** | BPMN · UML: диаграммы последовательности и состояний · PlantUML |
| **Требования** | бизнес-правила · функциональные / нефункциональные требования · сценарии использования · критерии приёмки |
| **Инструменты** | Git · GitLab CI · Python |

---

## 📱 следующий кейс

**«Смена» / FitnessTech** — системная проработка мобильной игровой функции: жизненный цикл пользовательской сессии, состояния, продуктовые события, API и модель данных.

Пока не выношу сюда несуществующие спецификации: отдельная ссылка появится вместе с самими артефактами.

---

<div align="center">

[![GitHub Profile](https://img.shields.io/badge/←_В_ПРОФИЛЬ-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/spicerrr)

</div>
