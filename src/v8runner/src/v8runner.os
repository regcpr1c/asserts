﻿
///////////////////////////////////////////////////////////////////////////////////
// УПРАВЛЕНИЕ ЗАПУСКОМ КОМАНД 1С:Предприятия 8
//

#Использовать logos

Перем мКонтекстКоманды;
Перем мКаталогСборки;
Перем мВыводКоманды;
Перем мПутьКПлатформе1С;

Перем Лог;

//////////////////////////////////////////////////////////////////////////////////
// Программный интерфейс

Процедура УстановитьКонтекст(Знач СтрокаСоединения, Знач Пользователь, Знач Пароль) Экспорт
	мКонтекстКоманды.КлючСоединенияСБазой = СтрокаСоединения;
	мКонтекстКоманды.ИмяПользователя = Пользователь;
	мКонтекстКоманды.Пароль = Пароль;
КонецПроцедуры

Функция ПолучитьКонтекст() Экспорт
	КопияКонтекста = СкопироватьСтруктуру(мКонтекстКоманды);
	Возврат КопияКонтекста;
КонецФункции

Процедура ИспользоватьКонтекст(Знач Контекст) Экспорт
	мКонтекстКоманды = СкопироватьСтруктуру(Контекст);
КонецПроцедуры

Функция ПолучитьВерсиюИзХранилища(Знач СтрокаСоединения, Знач ПользовательХранилища, Знач ПарольХранилища, Знач НомерВерсии = Неопределено) Экспорт
	
	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
	
	Параметры.Добавить("/ConfigurationRepositoryF """+СтрокаСоединения+"""");
	Параметры.Добавить("/ConfigurationRepositoryN """+ПользовательХранилища+"""");
	
	Если Не ПустаяСтрока(ПарольХранилища) Тогда
		Параметры.Добавить("/ConfigurationRepositoryP """+ПарольХранилища+"""");
	КонецЕсли;
	
	ФайлРезультата = КаталогСборки()+"\source.cf";
	
	Параметры.Добавить("/ConfigurationRepositoryDumpCfg """+ФайлРезультата + """");
	
	Если Не ПустаяСтрока(НомерВерсии) Тогда
		Параметры.Добавить("-v "+НомерВерсии);
	КонецЕсли;
	
	ВыполнитьКоманду(Параметры);
	
	Возврат ФайлРезультата;
	
КонецФункции

Процедура ЗагрузитьКонфигурациюИзФайла(Знач ФайлКонфигурации, Знач ОбновитьКонфигурациюИБ = Ложь) Экспорт
	
	// Выполняем загрузку и обновление за два шага, т.к.
	// иногда обновление конфигурации ИБ на новой базе проходит неудачно,
	// если запустить две операции в одной команде.
	
	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
	Параметры.Добавить("/LoadCfg """ + ФайлКонфигурации + """");
	ВыполнитьКоманду(Параметры);
	
	Если ОбновитьКонфигурациюИБ Тогда
		Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
		Параметры.Добавить("/UpdateDBCfg -Server");
		ВыполнитьКоманду(Параметры);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьКонфигурациюБазыДанных(ПредупрежденияКакОшибки = Ложь, НаСервере = Истина) Экспорт
	
	ПараметрыСвязиСБазой = СтандартныеПараметрыЗапускаКонфигуратора();
	ПараметрыСвязиСБазой.Добавить("/UpdateDBCfg");
	Если ПредупрежденияКакОшибки Тогда
		ПараметрыСвязиСБазой.Добавить("-WarningsAsErrors");
	КонецЕсли;
	Если НаСервере Тогда
		ПараметрыСвязиСБазой.Добавить("-Server");
	КонецЕсли;
	
	ВыполнитьКоманду(ПараметрыСвязиСБазой);
	
КонецПроцедуры

Процедура ОбновитьКонфигурацию(Знач КаталогВерсии, Знач ИспользоватьПолныйДистрибутив = Ложь) Экспорт
	
	ПараметрыЗапуска = СтандартныеПараметрыЗапускаКонфигуратора();
	
	Если ИспользоватьПолныйДистрибутив = Неопределено Тогда
		ИспользоватьПолныйДистрибутив = Не КаталогСодержитФайлОбновления(КаталогВерсии);
	КонецЕсли;
	
	Если ИспользоватьПолныйДистрибутив Тогда
		ФайлОбновления = "1cv8.cf";
	Иначе
		ФайлОбновления = "1cv8.cfu";
	КонецЕсли;
	
	ПараметрыЗапуска.Добавить("/UpdateCfg " + ОбернутьВКавычки(КаталогВерсии + "\" + ФайлОбновления));
	
	ВыполнитьКоманду(ПараметрыЗапуска);
	
КонецПроцедуры

Процедура СоздатьФайловуюБазу(Знач КаталогБазы) Экспорт

	ОбеспечитьКаталог(КаталогБазы);
	УдалитьФайлы(КаталогБазы, "*.*");
	
	ПараметрыЗапуска = Новый Массив;
	ПараметрыЗапуска.Добавить("CREATEINFOBASE");
	ПараметрыЗапуска.Добавить("File="""+КаталогБазы+"""");
	ПараметрыЗапуска.Добавить("/Out""" + ФайлИнформации() + """");
	
	КодВозврата = ЗапуститьИПодождать(ПараметрыЗапуска);
	УстановитьВывод(ПрочитатьФайлИнформации());
	Если КодВозврата <> 0 Тогда
		ВызватьИсключение ВыводКоманды();
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Параметры) Экспорт
	
	ПроверитьВозможностьВыполненияКоманды();
	
	КодВозврата = ЗапуститьИПодождать(Параметры);
	УстановитьВывод(ПрочитатьФайлИнформации());
	Если КодВозврата <> 0 Тогда
		ВызватьИсключение ВыводКоманды();
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьПараметрыЗапуска() Экспорт
	Возврат СтандартныеПараметрыЗапускаКонфигуратора();
КонецФункции

Процедура ВыполнитьСинтаксическийКонтроль(
			Знач ТонкийКлиент = Истина,
			Знач ВебКлиент = Истина,
			Знач Сервер = Истина,
			Знач ВнешнееСоединение = Истина,
			Знач ТолстыйКлиентОбычноеПриложение = Истина) Экспорт
	
	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();

	Параметры.Добавить("/CheckModules");
	
	ДобавитьФлагПроверки(Параметры, ТонкийКлиент, "-ThinClient");
    ДобавитьФлагПроверки(Параметры, ВебКлиент, "-WebClient");
    ДобавитьФлагПроверки(Параметры, Сервер, "-Server");
    ДобавитьФлагПроверки(Параметры, ВнешнееСоединение, "-ExternalConnection");
    ДобавитьФлагПроверки(Параметры, ТолстыйКлиентОбычноеПриложение, "-ThickClientOrdinaryApplication");
	
	ВыполнитьКоманду(Параметры);
	
КонецПроцедуры

Процедура ЗапуститьВРежимеПредприятия(Знач КлючЗапуска = "MIGRATE", Знач УправляемыйРежим = Неопределено, Знач ДополнительныеКлючи = Неопределено) Экспорт
	ПараметрыСвязиСБазой = ПолучитьПараметрыЗапуска();
	ПараметрыСвязиСБазой[0] = "ENTERPRISE";
	ПараметрыСвязиСБазой.Добавить("/C"+КлючЗапуска);
	Если УправляемыйРежим = Истина Тогда
		ПараметрыСвязиСБазой.Вставить(2, "/RunModeManagedApplication");
	ИначеЕсли УправляемыйРежим = Ложь Тогда
		ПараметрыСвязиСБазой.Вставить(2, "/RunModeOrdinaryApplication");
	КонецЕсли;
	
	Если ДополнительныеКлючи <> Неопределено Тогда
		ПараметрыСвязиСБазой.Добавить(ДополнительныеКлючи);
	КонецЕсли;
	
	ВыполнитьКоманду(ПараметрыСвязиСБазой);

КонецПроцедуры

Процедура ДобавитьФлагПроверки(Знач Параметры, Знач ФлагПроверки, Знач ИмяФлага)
	
	Если ФлагПроверки Тогда
		Параметры.Добавить(ИмяФлага);
	КонецЕсли;
	
КонецПроцедуры

Функция КаталогСодержитФайлОбновления(Знач КаталогВерсии)
	
	ФайлОбновления = Новый Файл(КаталогВерсии + "\1cv8.cfu");
	Возврат ФайлОбновления.Существует();
	
КонецФункции

Функция ПутьКВременнойБазе() Экспорт
	Возврат КаталогСборки() + "\v8r_TempDB";
КонецФункции

//////////////////////////////////////////////////
// Вспомогательные и настроечные функции

Функция ПолучитьПутьКВерсииПлатформы(Знач ВерсияПлатформы) Экспорт

	Если Лев(ВерсияПлатформы, 2) <> "8." Тогда
		ВызватьИсключение "Неверная версия платформы <"+ВерсияПлатформы+">";
	КонецЕсли;	
	
	путьProgramFiles = "C:\Program Files (x86)\";
	файлProgramFiles = Новый Файл(путьProgramFiles);
	Если Не файлProgramFiles.Существует() Тогда
		путьProgramFiles = "C:\Program Files\";
		файлProgramFiles = Новый Файл(путьProgramFiles);
		Если Не файлProgramFiles.Существует() Тогда
			ВызватьИсключение "Должен существовать путь к Program Files или Program Files (86)";
		КонецЕсли;
		
	КонецЕсли;
	
	СписокСтрок = РазложитьСтрокуВМассивПодстрок(ВерсияПлатформы, ".");
	Если СписокСтрок.Количество() < 2 Тогда
		ВызватьИсключение "Маска версии платформы должна содержать, как минимум, минорную и мажорную версию, т.е. Maj.Min[.Release][.Build]";
	КонецЕсли;
	
	МажорнаяВерсия = СписокСтрок[0];
	МинорнаяВерсия = СписокСтрок[1];
	
	Если МинорнаяВерсия = "3" Тогда // 8.3
		путьКПлатформе = путьProgramFiles + "1cv8\";
	ИначеЕсли МинорнаяВерсия = "2" Тогда // 8.2
		путьКПлатформе = путьProgramFiles + "1cv82\";	
	ИначеЕсли МинорнаяВерсия = "1" Тогда // 8.1
		путьКПлатформе = путьProgramFiles + "1cv81\";
	Иначе
		ВызватьИсключение "Неверная версия платформы <"+ВерсияПлатформы+">";
	КонецЕсли;
	
	МассивФайлов = НайтиФайлы(путьКПлатформе, версияПлатформы+"*");
	Если МассивФайлов.Количество() = 0 Тогда
		ВызватьИсключение "Не найден путь к платформе 1С <"+версияПлатформы+">";
	КонецЕсли;
	
	ИменаВерсий = Новый Массив;
	Для Каждого ЭлементМассива Из МассивФайлов Цикл
		правыйСимвол = Прав(ЭлементМассива.Имя,1);
		Если правыйСимвол < "0" или правыйСимвол > "9" Тогда
			Продолжить;
		КонецЕсли;
		ИменаВерсий.Добавить(ЭлементМассива.Имя);
	КонецЦикла;
	
	МаксВерсия = ИменаВерсий[0];
	Для Сч = 1 По ИменаВерсий.Количество()-1 Цикл
		Если МаксВерсия < ИменаВерсий[Сч] Тогда
			МаксВерсия = ИменаВерсий[Сч];
		КонецЕсли;
	КонецЦикла;
	
	НужныйПуть = Новый Файл(путьКПлатформе + МаксВерсия + "\bin\1cv8.exe");
	Если Не НужныйПуть.Существует() Тогда
		ВызватьИсключение "Ошибка определения версии платформы. Файл <"+НужныйПуть.ПолноеИмя+"> не существует";
	КонецЕсли;
	
	Возврат НужныйПуть.ПолноеИмя;
	
КонецФункции

Процедура УстановитьКлючРазрешенияЗапуска(Знач Ключ) Экспорт
	мКонтекстКоманды.КлючРазрешенияЗапуска = Ключ;
КонецПроцедуры

Функция ВыводКоманды() Экспорт
	Возврат мВыводКоманды;
КонецФункции

Функция КаталогСборки(Знач Каталог = "") Экспорт
	
	Если мКаталогСборки = Неопределено Тогда
		мКаталогСборки = ТекущийКаталог();
	КонецЕсли;
	
	Если Каталог = "" Тогда
		Возврат мКаталогСборки;
	Иначе
		ТекКаталог = мКаталогСборки;
		мКаталогСборки = Каталог;
		Возврат ТекКаталог;
	КонецЕсли;
	
КонецФункции

Функция ПутьКПлатформе1С(Знач Путь = "") Экспорт

	Если Путь = "" Тогда
		Возврат мПутьКПлатформе1С;
	Иначе
		ТекЗначение = мПутьКПлатформе1С;
		мПутьКПлатформе1С = Путь;
		Возврат ТекЗначение;
	КонецЕсли;

КонецФункции

Процедура ИспользоватьВерсиюПлатформы(Знач МаскаВерсии) Экспорт
	Путь = ПолучитьПутьКВерсииПлатформы(МаскаВерсии);
	ПутьКПлатформе1С(Путь);
КонецПроцедуры

Функция ПутьКТонкомуКлиенту1С(Знач ПутьКПлатформе1С = "") Экспорт
	Сообщить("ПутьКТонкомуКлиенту1С: Путь платформы 1С <"+ПутьКПлатформе1С+">");
	Если ПутьКПлатформе1С = "" Тогда
		ПутьКПлатформе1С = ПутьКПлатформе1С();
		Сообщить("ПутьКТонкомуКлиенту1С: вычислили Путь платформы 1С <"+ПутьКПлатформе1С+">");
	КонецЕсли;
	
	ФайлПриложения = Новый Файл(ПутьКПлатформе1С);
	Каталог = ФайлПриложения.Путь;
	ФайлПриложения = Новый Файл(Каталог + "\1cv8c.exe");
	Если Не ФайлПриложения.Существует() Тогда
		ВызватьИсключение "Не установлен тонкий клиент";
	КонецЕсли;
		
	Сообщить("ПутьКТонкомуКлиенту1С: получили путь к тонкому клиенту 1С <"+ФайлПриложения.ПолноеИмя+">");
	Возврат ФайлПриложения.ПолноеИмя;

Процедура УдалитьВременнуюБазу() Экспорт

	Если ВременнаяБазаСуществует() Тогда
		КаталогВременнойБазы = ПутьКВременнойБазе();
		УдалитьФайлы(КаталогВременнойБазы);
	КонецЕсли;
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры

Функция СтандартныеПараметрыЗапускаКонфигуратора()

	ПараметрыЗапуска = Новый Массив;
	ПараметрыЗапуска.Добавить("DESIGNER");
	ПараметрыЗапуска.Добавить(КлючСоединенияСБазой());
	ПараметрыЗапуска.Добавить("/Out" + ОбернутьВКавычки(ФайлИнформации()));
	Если Не ПустаяСтрока(мКонтекстКоманды.ИмяПользователя) Тогда
		ПараметрыЗапуска.Добавить("/N" + ОбернутьВКавычки(мКонтекстКоманды.ИмяПользователя));
	КонецЕсли;
	Если Не ПустаяСтрока(мКонтекстКоманды.Пароль) Тогда
		ПараметрыЗапуска.Добавить("/P" + ОбернутьВКавычки(мКонтекстКоманды.Пароль));
	КонецЕсли;
	ПараметрыЗапуска.Добавить("/WA+");
	Если Не ПустаяСтрока(мКонтекстКоманды.КлючРазрешенияЗапуска) Тогда
		ПараметрыЗапуска.Добавить("/UC" + ОбернутьВКавычки(мКонтекстКоманды.КлючРазрешенияЗапуска));
	КонецЕсли;
	ПараметрыЗапуска.Добавить("/DisableStartupMessages");
	ПараметрыЗапуска.Добавить("/DisableStartupDialogs");
	
	Возврат ПараметрыЗапуска;

КонецФункции

Процедура ПроверитьВозможностьВыполненияКоманды()

	Если Не ЗначениеЗаполнено(ПутьКПлатформе1С()) Тогда
		ВызватьИсключение "Не задан путь к платформе 1С";
	КонецЕсли;
	
	Если КлючСоединенияСБазой() = КлючВременногоКонтекста() и Не ВременнаяБазаСуществует() Тогда
		СоздатьВременнуюБазу();
	КонецЕсли;

КонецПроцедуры

Функция КлючСоединенияСБазой()
	Если ПустаяСтрока(мКонтекстКоманды.КлючСоединенияСБазой) Тогда
		Возврат КлючВременногоКонтекста();
	Иначе
		Возврат мКонтекстКоманды.КлючСоединенияСБазой;
	КонецЕсли;
КонецФункции

Процедура СоздатьВременнуюБазу()

	КаталогВременнойБазы = ПутьКВременнойБазе();
	
	СоздатьФайловуюБазу(КаталогВременнойБазы);
	
КонецПроцедуры

Функция ЗапуститьИПодождать(Знач Параметры)

	СтрокаЗапуска = "";
	СтрокаДляЛога = "";
	Для Каждого Параметр Из Параметры Цикл
	
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		
		Если Лев(Параметр,2) <> "/P" и Лев(Параметр,25) <> "/ConfigurationRepositoryP" Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;
	
	КонецЦикла;

	КодВозврата = 0;
	
	Приложение = ОбернутьВКавычки(ПутьКПлатформе1С());
	Лог.Отладка(Приложение + СтрокаДляЛога);
	
	ЗапуститьПриложение(Приложение + СтрокаЗапуска, , Истина, КодВозврата);
	
	Возврат КодВозврата;

КонецФункции

Функция ПрочитатьФайлИнформации()

	Текст = "";

	Файл = Новый Файл(ФайлИнформации());
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеТекста(Файл.ПолноеИмя);
		Текст = Чтение.Прочитать();
		Чтение.Закрыть();
	Иначе
		Текст = "Информации об ошибке нет";
	КонецЕсли;

	Возврат Текст;
	
КонецФункции

Процедура УстановитьВывод(Знач Сообщение)
	мВыводКоманды = Сообщение;
КонецПроцедуры

Функция ФайлИнформации()
	Возврат КаталогСборки() + "\log.txt";
КонецФункции

Процедура ОбеспечитьКаталог(Знач Каталог)

	Файл = Новый Файл(Каталог);
	Если Не Файл.Существует() Тогда
		СоздатьКаталог(Каталог);
	ИначеЕсли Не Файл.ЭтоКаталог() Тогда
		ВызватьИсключение "Каталог " + Каталог + " не является каталогом";
	КонецЕсли;

КонецПроцедуры

Функция КлючВременногоКонтекста()
	Возврат "/F""" + ПутьКВременнойБазе() + """";
КонецФункции

Функция ВременнаяБазаСуществует() Экспорт
	ФайлБазы = Новый Файл(ПутьКВременнойБазе() + "\1cv8.1cd");
	Возврат ФайлБазы.Существует();
КонецФункции

Функция РазложитьСтрокуВМассивПодстрок(ИсходнаяСтрока, Разделитель)

	МассивПодстрок = Новый Массив;
	ОстатокСтроки = ИсходнаяСтрока;
	
	Поз = -1;
	Пока Поз <> 0 Цикл
	
		Поз = Найти(ОстатокСтроки, Разделитель);
		Если Поз > 0 Тогда
			Подстрока = Лев(ОстатокСтроки, Поз-1);
			ОстатокСтроки = Сред(ОстатокСтроки, Поз+1);
		Иначе
			Подстрока = ОстатокСтроки;
		КонецЕсли;
		
		МассивПодстрок.Добавить(Подстрока);
	
	КонецЦикла;
	
	Возврат МассивПодстрок;

КонецФункции

Функция ОбернутьВКавычки(Знач Строка);
	Если Лев(Строка, 1) = """" и Прав(Строка, 1) = """" Тогда
		Возврат Строка;
	Иначе
		Возврат """" + Строка + """";
	КонецЕсли;
КонецФункции

Процедура Инициализация()

	мКонтекстКоманды = Новый Структура;
	мКонтекстКоманды.Вставить("КлючСоединенияСБазой", "");
	мКонтекстКоманды.Вставить("ИмяПользователя", "");
	мКонтекстКоманды.Вставить("Пароль", "");
	мКонтекстКоманды.Вставить("КлючРазрешенияЗапуска", "");
	
	ПутьКПлатформе1С(ПолучитьПутьКВерсииПлатформы("8.3"));
	Лог = Логирование.ПолучитьЛог("oscript.lib.v8runner");

КонецПроцедуры

Функция СкопироватьСтруктуру(Знач Источник)
	
	Копия = Новый Структура;
	Для Каждого КлючИЗначение Из Источник Цикл
		Копия.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
	КонецЦикла;
	
	Возврат Копия;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////////////
// Инициализация

Инициализация();