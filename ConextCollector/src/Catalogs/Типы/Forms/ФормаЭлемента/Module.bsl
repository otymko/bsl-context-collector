#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Версии.Параметры.УстановитьЗначениеПараметра("Владелец", Объект.Ссылка);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	Версии.Параметры.УстановитьЗначениеПараметра("Владелец", Объект.Ссылка);
	Элементы.Версии.Обновить();
	
КонецПроцедуры

#КонецОбласти