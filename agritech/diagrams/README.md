# Диаграммы

[← К кейсу](../README.md)

Диаграммы встроены в соответствующие документы. SVG можно открыть прямо на GitHub; файлы PlantUML и BPMN предназначены для редактирования.

| Модель | Какой вопрос решает | Изображение | Исходник |
|:---|:---|:---|:---|
| Источники и расчёт показателей | Как данные подразделений превращаются в показатели «Паспорта сорта» | [SVG](rendered/passport-data.svg) | Редактируемый SVG |
| Исходные данные · UML | Какие записи существуют до изменения и как они связаны | [SVG](rendered/as-is-data.svg) | [PlantUML](as-is-data.puml) |
| Целевые данные · UML | Какие сущности, ключи и связи нужны для учёта партии | [SVG](rendered/data-model.svg) | [PlantUML](data-model.puml) |
| Исходный процесс · UML activity | Где вводят и вручную сверяют документы | [SVG](rendered/as-is-process.svg) | [PlantUML](as-is-process.puml) |
| Целевой процесс · UML activity | Как меняются шаги участников после связывания данных | [SVG](rendered/to-be-process.svg) | [PlantUML](to-be-process.puml) |
| Сценарии · UML use case | Какие задачи решают участники | [SVG](rendered/use-cases.svg) | [PlantUML](use-cases.puml) |
| Регистрация · UML sequence | Как сохраняются сбор и сообщение, когда возвращается ответ | [SVG](rendered/sequence.svg) | [PlantUML](sequence.puml) |
| Приёмка · UML sequence | Как WMS подтверждает приёмку и передаёт сведения получателям | [SVG](rendered/receipt-sequence.svg) | [PlantUML](receipt-sequence.puml) |
| Состояния · UML state | Как различаются регистрация, публикация сообщения и получение приёмки | [SVG](rendered/states.svg) | [PlantUML](states.puml) |
| Взаимодействие производства и склада · BPMN 2.0 | Какие действия выполняются внутри каждого участника и какие сообщения передаются между ними | — | [BPMN](batch-process.bpmn) |

[Порядок обновления изображений](../docs/versioning.md#обновление-диаграмм).
