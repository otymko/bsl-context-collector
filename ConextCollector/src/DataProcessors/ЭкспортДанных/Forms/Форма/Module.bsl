#Область ОбработчикиСобытий

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// FIXME: перейти на опцию обработки или вынести в расширение
	ТестовыеДанные();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЭкспортироватьДанные(Команда)
	
	// FIXME: исправить поддержку передачи файлов сервер -> клиент

	Если ПустаяСтрока(Объект.КаталогЭкспорта) Тогда
		ОбщийМодуль.СообщитьПользователю("КаталогЭкспорта не заполнен");
		Возврат;	
	КонецЕсли;
	
	Если Объект.ВыгрузитьИдентификаторыТипов Тогда
		ВыгрузитьИдентификаторыТипов(Объект.КаталогЭкспорта);	
	КонецЕсли;
	
	Если Объект.ВыгрузитьДанные Тогда
		ВыгрузитьДанные(Объект.КаталогЭкспорта);	
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВыгрузитьИдентификаторыТипов(Каталог)
	ИмяФайла = "type-identifiers.json";
	Данные = ДанныеИдентификаторовТипов();
	
	ДанныеФайла = ШаблонЗаписиИдентификаторовТипов();
	
	Для Каждого ИнформацияОТипе Из Данные Цикл
		
		Идентификатор = ИнформацияОТипе.Идентификатор;
		Если ПустаяСтрока(Идентификатор) Тогда
			Продолжить;
		КонецЕсли;
		
		Запись = ШаблонЗаписиИдентификатораТипа();
		Запись.Id = Идентификатор;
		Запись.Name = ИнформацияОТипе.НаименованиеАнгл;
		Запись.NameRu = ИнформацияОТипе.Наименование;
		
		ДанныеФайла.Identifiers.Добавить(Запись);
		
	КонецЦикла;
	
	ПутьКФайлу = Каталог + ИмяФайла;
	ЗаписатьДанныеВФайл(ДанныеФайла, ПутьКФайлу);
	
КонецПроцедуры

&НаСервере
Процедура ВыгрузитьДанные(Каталог)
	
	Если ЗначениеЗаполнено(Объект.ВерсияПлатформы) Тогда
		ВыгрузитьДанныеПоВерсииПлатформы(Объект.ВерсияПлатформы, Каталог);	
	Иначе
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	ВерсииТипов.ВерсияПлатформы КАК ВерсияПлатформы
		               |ИЗ
		               |	Справочник.ВерсииТипов КАК ВерсииТипов
		               |
		               |СГРУППИРОВАТЬ ПО
		               |	ВерсииТипов.ВерсияПлатформы";
		ВыборкаВерсий = Запрос.Выполнить().Выбрать();
		Пока ВыборкаВерсий.Следующий() Цикл
			ВыгрузитьДанныеПоВерсииПлатформы(ВыборкаВерсий.ВерсияПлатформы, Каталог);	
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВыгрузитьДанныеПоВерсииПлатформы(ВерсияПлатформы, Каталог)

	ВерсияПлатформыСтрокой = СтрЗаменить(Строка(ВерсияПлатформы), ".", "_"); 
	
	МодельДанных = Новый Структура;
	МодельДанных.Вставить("platformVersion");
	МодельДанных.Вставить("types", Новый Массив);
	МодельДанных.Вставить("events", Новый Массив);
	
	
	МодельДанных.platformVersion = ВерсияПлатформыСтрокой;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВерсииТипов.Ссылка КАК Ссылка,
	               |	ВерсииТипов.Идентификатор КАК Идентификатор,
	               |	ВерсииТипов.Наименование КАК Наименование,
	               |	ВерсииТипов.НаименованиеАнгл КАК НаименованиеАнгл
	               |ПОМЕСТИТЬ Типы
	               |ИЗ
	               |	Справочник.ВерсииТипов КАК ВерсииТипов
	               |ГДЕ
	               |	ВерсииТипов.ВерсияПлатформы = &ВерсияПлатформы
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Типы.Ссылка КАК Ссылка,
	               |	Типы.Идентификатор КАК Идентификатор,
	               |	Типы.Наименование КАК Наименование,
	               |	Типы.НаименованиеАнгл КАК НаименованиеАнгл,
	               |	Типы.Ссылка.Перечисление КАК ЭтоПеречисление,
	               |	Типы.Ссылка.Владелец.ИсключитьИзГлобальногоКонтекста КАК ИсключитьИзГлобальногоКонтекста
	               |ИЗ
	               |	Типы КАК Типы
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Типы.Ссылка КАК СсылкаНаТип,
	               |	Методы.Ссылка КАК СсылкаНаМетод,
	               |	Методы.Наименование КАК Наименование,
	               |	Методы.НаименованиеАнгл КАК НаименованиеАнгл
	               |ИЗ
	               |	Типы КАК Типы
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Методы КАК Методы
	               |		ПО Типы.Ссылка = Методы.Владелец
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	События.Ссылка КАК Ссылка,
	               |	События.Наименование КАК Наименование,
	               |	События.НаименованиеАнгл КАК НаименованиеАнгл,
	               |	События.Владелец.Идентификатор КАК ИдентификаторТипа
	               |ИЗ
	               |	Справочник.События КАК События
	               |ГДЕ
	               |	События.ВерсияПлатформы = &ВерсияПлатформы
	               |ИТОГИ ПО
	               |	Наименование
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Свойства.Владелец КАК СсылкаНаТип,
	               |	Свойства.Ссылка КАК Ссылка,
	               |	Свойства.Наименование КАК Наименование,
	               |	Свойства.НаименованиеАнгл КАК НаименованиеАнгл,
	               |	Свойства.Владелец.Идентификатор КАК ИдентификаторТипа,
	               |	Свойства.РежимИспользования КАК РежимИспользования
	               |ИЗ
	               |	Справочник.Свойства КАК Свойства
	               |ГДЕ
	               |	Свойства.ВерсияПлатформы = &ВерсияПлатформы";
	Запрос.УстановитьПараметр("ВерсияПлатформы", ВерсияПлатформы);
	ПакетЗапросов = Запрос.ВыполнитьПакет();
	ВыборкаТипов = ПакетЗапросов[1].Выбрать();
	ВыборкаМетодов = ПакетЗапросов[2].Выгрузить();
	ВыборкаСобытий = ПакетЗапросов[3].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ВыборкаСвойств = ПакетЗапросов[4].Выгрузить();
	ВыборкаЗначенийТипов = Неопределено;
	
	Пока ВыборкаТипов.Следующий() Цикл
		
		МодельТипа = МодельТипа();
		МодельТипа.id = ВыборкаТипов.Идентификатор;
		МодельТипа.name = ВыборкаТипов.НаименованиеАнгл;
		МодельТипа.nameRu = ВыборкаТипов.Наименование;
		Если (ВыборкаТипов.ЭтоПеречисление) Тогда
			МодельТипа.kind = "Enum";	
		КонецЕсли;
		МодельТипа.excludeFromGlobalContext = ВыборкаТипов.ИсключитьИзГлобальногоКонтекста; 
		
		Отбор = Новый Структура("СсылкаНаТип", ВыборкаТипов.Ссылка);
		РезультатПоискаМетодов = ВыборкаМетодов.НайтиСтроки(Отбор);
		Для Каждого СтрокаСМетодом Из РезультатПоискаМетодов Цикл
			
			МодельМетода = МодельМетода();
			МодельМетода.name = СтрокаСМетодом.НаименованиеАнгл;
			МодельМетода.nameRu = СтрокаСМетодом.Наименование;
			// FIXME: x2
			МодельМетода.isFunction = СтрокаСМетодом.СсылкаНаМетод.ВозвращаемыеЗначения.Количество() > 0;
			МодельТипа.methods.Добавить(МодельМетода);
				
		КонецЦикла;
		
		РезультатПоискаСвойств = ВыборкаСвойств.НайтиСтроки(Отбор);
		Для Каждого СтрокаСоСвойством Из РезультатПоискаСвойств Цикл
		
			МодельСвойства = МодельСвойства();
			МодельСвойства.name = СтрокаСоСвойством.НаименованиеАнгл;
			МодельСвойства.nameRu = СтрокаСоСвойством.Наименование;
			МодельСвойства.usage = ПредставлениеРежимаИспользования(СтрокаСоСвойством.РежимИспользования);
			МодельТипа.properties.Добавить(МодельСвойства);
			
		КонецЦикла;
		
		РезультатПоискаЗначений = ВыборкаЗначенийТипов.НайтиСтроки(Отбор);
		Для Каждого СтрокаЗначения Из РезультатПоискаЗначений Цикл	
			МодельЗначения = МодельЗначения();
			МодельЗначения.name = СтрокаЗначения.НаименованиеАнгл;
			МодельЗначения.nameRu = СтрокаЗначения.Наименование;
			МодельТипа.values.Добавить(МодельЗначения);
		КонецЦикла;
		
		МодельДанных.types.Добавить(МодельТипа);
		
	КонецЦикла;
	
	Пока ВыборкаСобытий.Следующий() Цикл
		
		МодельСобытия = МодельСобытия();
		МодельСобытия.nameRu = ВыборкаСобытий.Наименование;
		
		ВыборкаПоТипам = ВыборкаСобытий.Выбрать();
		Пока ВыборкаПоТипам.Следующий() Цикл
			Если Не ЗначениеЗаполнено(МодельСобытия.name) Тогда
				МодельСобытия.name = ВыборкаПоТипам.НаименованиеАнгл;	
			КонецЕсли;
			МодельСобытия.types.Добавить(ВыборкаПоТипам.ИдентификаторТипа);
		КонецЦикла;
		
		МодельДанных.events.Добавить(МодельСобытия);
		
	КонецЦикла;
	
	ПутьКФайлу = СтрШаблон("%1%2.json", Каталог, ВерсияПлатформыСтрокой);
	ЗаписатьДанныеВФайл(МодельДанных, ПутьКФайлу);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция МодельТипа()
	Модель = Новый Структура;
	Модель.Вставить("id");
	Модель.Вставить("name");
	Модель.Вставить("nameRu");
	Модель.Вставить("kind", "Type");
	Модель.Вставить("methods", Новый Массив);
	Модель.Вставить("properties", Новый Массив);
	Модель.Вставить("values", Новый Массив);
	Модель.Вставить("excludeFromGlobalContext", Ложь);
	Возврат Модель;	
КонецФункции

&НаСервереБезКонтекста
Функция МодельМетода()
	Модель = Новый Структура;
	Модель.Вставить("name");
	Модель.Вставить("nameRu");
	Модель.Вставить("isFunction");
	Возврат Модель;	
КонецФункции

&НаСервереБезКонтекста
Функция МодельСобытия()
	Модель = Новый Структура;
	Модель.Вставить("name");
	Модель.Вставить("nameRu");
	Модель.Вставить("types", Новый Массив);
	Возврат Модель;	
КонецФункции

&НаСервереБезКонтекста
Функция МодельСвойства()
	Модель = Новый Структура;
	Модель.Вставить("name");
	Модель.Вставить("nameRu");
	Модель.Вставить("usage");
	Возврат Модель;
КонецФункции

&НаСервереБезКонтекста
Функция МодельЗначения()
	Модель = Новый Структура;
	Модель.Вставить("name");
	Модель.Вставить("nameRu");
	Возврат Модель;	
КонецФункции

&НаСервереБезКонтекста
Процедура ЗаписатьДанныеВФайл(Данные, ПутьКФайлу)
	Запись = Новый ЗаписьJSON;
	Запись.ОткрытьФайл(ПутьКФайлу);		
	ЗаписатьJSON(Запись, Данные);
	Запись.Закрыть();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеИдентификаторовТипов()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Типы.Идентификатор КАК Идентификатор,
	|	Типы.Наименование Как Наименование,
	|	Типы.НаименованиеАнгл Как НаименованиеАнгл
	|ИЗ
	|	Справочник.Типы КАК Типы
	|ГДЕ
	|	НЕ Типы.ЭтоГруппа
	|	И НЕ Типы.ПометкаУдаления
	|УПОРЯДОЧИТЬ ПО
	|	Идентификатор";
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

&НаСервереБезКонтекста
Функция ШаблонЗаписиИдентификаторовТипов()
	Возврат Новый Структура("Identifiers", Новый Массив);	
КонецФункции

&НаСервереБезКонтекста
Функция ШаблонЗаписиИдентификатораТипа()
	Шаблон = Новый Структура;
	Шаблон.Вставить("Id", "");	
	Шаблон.Вставить("Name", "");
	Шаблон.Вставить("NameRu", "");
	Возврат Шаблон;
КонецФункции

&НаСервере
Процедура ТестовыеДанные()
	Объект.КаталогЭкспорта = "D:\SB\develop\platform-context\export\";
	Объект.ВыгрузитьДанные = Истина;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПредставлениеРежимаИспользования(ВходящееЗначение)
	Если ВходящееЗначение = Перечисления.РежимИспользованияСвойства.ТолькоЗапись Тогда
		Возврат "WriteOnly";
	ИначеЕсли ВходящееЗначение = Перечисления.РежимИспользованияСвойства.ТолькоЧтение Тогда
		Возврат "ReadOnly";		
	КонецЕсли;
	Возврат "ReadAndWrite";
КонецФункции

#КонецОбласти
