--!strict
local GoodSignal = require(game.ReplicatedStorage.Shared.GoodSignal)
-- Класс баланса для хранения значения |денег?|
local Balance = {}
-- Типичное для луа игра с метатаблицами, просто, но со вкусом
Balance.__index = Balance

-- Обычный конструктор с необязательным 
-- аргументом startCapital, 
-- сразу изменяющий значение _capital,
-- где _capital - "приватное поле",
-- это и есть значение баланса
function Balance.new(startCapital: number?)
	local balance = setmetatable({}, Balance)

	balance._capital = startCapital or 0
	balance.Changed = GoodSignal.new()
	
	return balance
end
-- Обычный метод уничтожения/осовобождения памяти
function Balance:Destroy()
	self.Changed:Destroy()
	self.Changed = nil
	-- Просто удаляем все из таблички,
	-- не думаю что это необходимо,
	-- но подстраховаться стоит
	table.clear(self)
	self = nil
end
-- Это геттер для _capital поля
function Balance:GetCapital(): number
	return self._capital :: number
end
-- Метод для проверки способности покупки
function Balance:IsCanAfford(value: number): boolean
	return self._capital >= value
end
-- Это сеттер для _capital поля
-- Причем необычный сеттер, функция принимает также
-- отрицательные числа, как бы убавляя баланс,
-- + Простая, шустрая реализация
-- - Немножко странно, не интуитивно понятно
function Balance:AddCapital(numberToAdd: number)
	self._capital += numberToAdd
	self.Changed:Fire(self._capital)
end

return Balance