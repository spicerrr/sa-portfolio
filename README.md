<div align="center">

# System Analyst Portfolio

### системные требования · API · интеграции · модели данных

[![OpenAPI](https://img.shields.io/badge/OpenAPI_3.0-6BA539?style=flat-square&logo=swagger&logoColor=white)](#stack)
[![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=flat-square&logo=rabbitmq&logoColor=white)](#stack)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)](#stack)
[![BPMN](https://img.shields.io/badge/UML_%2F_BPMN-8250df?style=flat-square)](#stack)

[профиль](https://github.com/spicerrr) · [интеграционный кейс](#case-1) · [B2C-кейс](#case-2) · [стек](#stack) · [артефакты](#artifacts)

</div>

---

Портфолио системного аналитика с фокусом на **цифровые продукты и инженерную проработку функциональности**.

Основная логика работы здесь одна:  
пользовательский сценарий → системные требования → API / события → данные → ошибки → проверка.

Коммерческий контекст связан с внутренними системами и учётными процессами; в продуктовых кейсах тот же подход переносится на **Mobile / B2C**.

<a id="case-1"></a>

## 01 · интеграционный контур и справочные данные

> **Техническая реконструкция на базе коммерческого контекста.** Предметная проблема и типы данных основаны на рабочем опыте. Публичная архитектура, контракты и примеры обезличены и не являются внутренней документацией компании.

### задача

Несколько систем описывают один физический объект разными локальными кодами и документами. Сопоставление только по названию или дате приводит к дублям, неоднозначным связям и расхождениям между производственным и складским фактами.

### что спроектировано

| Уровень | Решение |
|:---|:---|
| **Справочные данные** | единый идентификатор сущности, соответствия локальных кодов, отдельная обработка неизвестных и конфликтующих значений |
| **REST API** | регистрация и чтение фактов, разрешение справочных кодов, ошибки и идемпотентные повторы |
| **Событийные интеграции** | RabbitMQ, JSON Schema событий, повторная доставка, DLQ, outbox / inbox, идентификатор корреляции |
| **Данные** | PostgreSQL, ERD, ограничения целостности, SQL-схема и отчётная витрина |
| **Переход исходных данных** | промежуточный слой, нормализация, поиск дублей и конфликтов, сохранение происхождения записи |
| **Проверка** | критерии приёмки, ошибочные сценарии и Python-валидация согласованности спецификаций |

### ключевые артефакты

| Артефакт | Ссылка |
|:---|:---|
| Контекст и границы | [docs/context.md](agritech/docs/context.md) |
| Требования | [docs/requirements.md](agritech/docs/requirements.md) |
| Сценарии использования | [docs/use-cases.md](agritech/docs/use-cases.md) |
| OpenAPI 3.0.3 | [contracts/openapi.yaml](agritech/contracts/openapi.yaml) |
| JSON Schema событий | [contracts/events.schema.json](agritech/contracts/events.schema.json) |
| Sequence / State / ERD / BPMN | [diagrams/](agritech/diagrams/) |
| PostgreSQL / SQL | [sql/](agritech/sql/) |
| Python-валидация | [scripts/](agritech/scripts/) |
| Проверка требований | [docs/acceptance.md](agritech/docs/acceptance.md) |

**Результат кейса:** одна трассируемая цепочка  
проблема → правило → контракт / данные → интеграция → сценарий проверки.

[**открыть кейс целиком →**](agritech/README.md)

<a id="case-2"></a>

## 02 · FitnessTech Mobile App

> **Следующий продуктовый кейс.** Ниже — границы задачи, а не заявленный промышленный опыт. Публичные спецификации появятся только после того, как требования, состояния, API и проверки будут согласованы между собой.

### что должен показать кейс

Мобильный B2C-сервис с подписочной моделью и несколькими связанными пользовательскими сценариями:

| Область | Что будет проработано |
|:---|:---|
| **Подписка** | оформление, продление, заморозка, отмена, права пользователя и переходы между состояниями |
| **Эквайринг** | создание платежа, подтверждение, дополнительное действие пользователя, webhooks, повторы и восстановление после сбоя |
| **Mobile API** | запросы клиента, состояния операций, ошибки, идемпотентность и согласованность статусов |
| **Push-уведомления** | сервисные уведомления, пользовательские настройки и связь уведомления с бизнес-событием |
| **Продуктовые события** | начало и завершение сценария, ошибки, конверсии и повторные действия |
| **B2C-сценарии** | основной поток, альтернативы, пограничные случаи, повторный запрос и восстановление после сетевой ошибки |

**План артефактов:**  
требования → State Machine → Sequence → ERD → OpenAPI → контракты событий → критерии приёмки.

Пока этот кейс не содержит проверяемого набора файлов, он не используется как доказательство владения отдельными технологиями в разделе стека.

<a id="stack"></a>

## 03 · стек

| Область | Уровень | Технологии / нотации | Где подтверждается |
|:---|:---|:---|:---|
| **Данные** | уверенно | PostgreSQL · SQL: DDL / DML, CTE · моделирование данных | [SQL](agritech/sql/) |
| **Моделирование** | уверенно | UML Sequence / State · ERD · BPMN 2.0 | [диаграммы](agritech/diagrams/) |
| **API** | проектная практика | REST / HTTP · OpenAPI 3.0.3 · Swagger · Postman · JSON Schema | [контракты](agritech/contracts/) |
| **Событийные интеграции** | проектная практика | RabbitMQ · JSON-события · повторная доставка · DLQ · outbox / inbox · идемпотентность | [интеграции](agritech/docs/integration.md) |
| **Требования** | рабочая / проектная практика | сценарии использования · бизнес-правила · функциональные и нефункциональные требования · критерии приёмки · трассировка | [docs](agritech/docs/) |
| **Инструменты** | рабочая / проектная практика | Git · GitLab CI · PlantUML · Python | [CI](agritech/gitlab-ci.example.yml) · [scripts](agritech/scripts/) |

<a id="artifacts"></a>

## 04 · артефакты

<div align="center">

[![Contracts](https://img.shields.io/badge/API_%26_CONTRACTS-6BA539?style=for-the-badge&logo=swagger&logoColor=white)](agritech/contracts/)
[![Diagrams](https://img.shields.io/badge/UML_%26_BPMN-8250df?style=for-the-badge)](agritech/diagrams/)
[![SQL](https://img.shields.io/badge/POSTGRESQL_%26_SQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](agritech/sql/)
[![Python](https://img.shields.io/badge/PYTHON_CHECKS-3776AB?style=for-the-badge&logo=python&logoColor=white)](agritech/scripts/)

</div>

| Раздел | Что открыть |
|:---|:---|
| **API и контракты** | [contracts](agritech/contracts/) |
| **UML / BPMN / ERD** | [diagrams](agritech/diagrams/) |
| **PostgreSQL / SQL** | [sql](agritech/sql/) |
| **Python-проверки** | [scripts](agritech/scripts/) |
| **Требования и анализ** | [docs](agritech/docs/) |

---

<div align="center">

[← GitHub profile](https://github.com/spicerrr)

</div>
