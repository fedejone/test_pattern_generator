
# Описание модуля 
### Адресное пространство. Адресация словная
|  Смещение | Режим  | Назначение | Описание | Примечание |
|--|--| --  |--   |--   |
| 0 |  | Режимы работы    | 0 - старт работы (активный 1) <br />  9 - выбор режима стандартных полос <br /> 10 - полосы со сдвигом <br />11 - картинка шахмат <br /> 12 - градиент <br /> 13 - монохром <br /> 17 - выбор режима Цветной или черно-белые цвета (активный чб)<br /> [8:1] - кол-во кадров для смены цветов<br />    |   |
| 1 |  | Ширина кадра  | [31:0]- ширина  |  |
| 2 |  | Высота кадра   | [31:0]- высота  |  |
| 3 |  | Развертка и цвет     | [7:0] - развертка <br /> [31:8] - если выбран монохром, то код цвета в RGB   |  |

**Примечание**
При увеличении разрешения более 1024 пикселей в ширину , кол-во полос при стандартном и режиме со сдвигом будет увеличиваться. Цветной градиент при достижении 1024 пикселей в ширину резко перейдет в другой цвет и будет продолжатся каждые 1024 пикселя в  ширину.

**Режим стандартных полос (полосы со сдвигом)**
![ ](/doc/1.jpg)
Черно-белый
![ ](/doc/2.jpg)
**Режим градиента**
![ ](/doc/3.jpg)
Черно-белый
![ ](/doc/4.jpg)
**Режим картинки шахмат**
![ ](/doc/5.jpg)
Режим одного цвета представляет монохромную статичное изображение (фон)


