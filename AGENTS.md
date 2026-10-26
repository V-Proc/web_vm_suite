# Архитектурный регламент для ИИ-агентов (FSD, БЭМ, Rails Services)

Этот документ определяет жесткие правила проектирования и написания кода для проекта управления виртуальными машинами (libvirt + Rails + React). Любой ИИ-агент, работающий с репозиторием, обязан строго соблюдать данные инструкции.

---

## 1. Архитектура Бэкенда (Ruby on Rails + Service Objects)

### 1.1. Тонкие модели и Контроллеры, Толстые Сервисы
Вся бизнес-логика, особенно интеграция с `libvirt` и оркестрация создания/настройки VM, должна выноситься в **Service Objects (Сервисы)**. 
- **Модели (`app/models`)**: Отвечают только за связи, валидации, скоупы и базовые состояния.
- **Контроллеры (`app/controllers`)**: Отвечают за парсинг параметров, вызов нужного сервиса и возврат JSON-ответа. Не содержат сложной логики.
- **Сервисы (`app/services`)**: Изолированные классы, выполняющие одно конкретное бизнес-действие (Single Responsibility).

### 1.2. Структура Сервисов
Сервисы должны располагаться в `app/services` и группироваться по бизнес-контексту (например, в подпапках `vms/`, `users/`, `workgroups/`).

**Паттерн реализации сервиса:**
```ruby
# app/services/vms/create_service.rb
module Vms
  class CreateService
    def initialize(user:, config_params:)
      @user = user
      @config_params = config_params
    end

    def call
      # 1. Валидация прав пользователя внутри воркгруппы
      # 2. Создание записи VirtualMachine в БД
      # 3. Генерация libvirt XML
      # 4. Вызов libvirt API для определения VM
      # Возвращает объект результата (Success/Failure)
    end
  end
end
```

### 1.3. Специфика работы с `libvirt`
- Все вызовы к `libvirt` инкапсулируются внутри сервисов (`Vms::StartService`, `Vms::StopService`, `Vms::DefineService`).
- Обязательна обработка исключений `Libvirt::Error` с логированием и возвратом понятных фронтенду ошибок.

---

## 2. Архитектура Фронтенда (React + Vite + TypeScript)

Фронтенд расположен строго в директории `app/javascript/`.

### 2.1. Feature-Sliced Design (FSD)
Код разделен на 6 стандартизированных слоев, идущих снизу вверх. Модуль с верхнего слоя не может импортировать код из слоев выше.

1. `shared` — переиспользуемый код, не привязанный к бизнес-логике (UI-кит, fetch-клиент, хелперы).
2. `entities` — бизнес-сущности (User, Workgroup, VirtualMachine, VirtualMachineConfig). Содержит их базовые интерфейсы, стейт-менеджеры (например, Zustand/Redux слайсы) и простые UI-карточки.
3. `features` — действия пользователя, несущие бизнес-ценность (например, `start-vm`, `create-config`, `invite-user`).
4. `widgets` — самостоятельные блоки страницы, объединяющие entities и features (например, `vm-list-table`, `sidebar`).
5. `pages` — композиционные экраны (например, `vm-details-page`, `dashboard-page`).
6. `app` — инициализация приложения, провайдеры, глобальные стили, роутинг.

**Правило Public API:** Каждый модуль (папка внутри слоя) должен иметь `index.ts`. Импорты извне этого модуля разрешены *только* через этот файл. Импорт внутренних файлов в обход `index.ts` запрещен.

### 2.2. БЭМ-методология (Блок, Элемент, Модификатор)
Стилизация компонентов выполняется через CSS/SCSS Modules.

- **Блок (Block):** Имя файла/компонента (например, `.vm-card {}`). Независимый компонент.
- **Элемент (Element):** Составляющая часть блока, которая не имеет смысла в отрыве от него. Отделяется двойным подчеркиванием (например, `.vm-card__status {}`).
- **Модификатор (Modifier):** Отвечает за состояние или внешний вид. Отделяется двойным дефисом (например, `.vm-card__status--active {}`, `.vm-card--selected {}`).

**Пример реализации на React + TypeScript:**
```tsx
// app/javascript/entities/virtual-machine/ui/vm-card/vm-card.module.scss
.vm-card {
  border: 1px solid #ccc;
  
  &__title {
    font-size: 1.2rem;
  }
  
  &__status {
    font-weight: bold;
    
    &--running { color: green; }
    &--stopped { color: red; }
  }
}

// app/javascript/entities/virtual-machine/ui/vm-card/vm-card.tsx
import styles from './vm-card.module.scss';

interface VmCardProps {
  name: string;
  status: 'running' | 'stopped';
}

export const VmCard = ({ name, status }: VmCardProps) => {
  return (
    <div className={styles['vm-card']}>
      <h3 className={styles['vm-card__title']}>{name}</h3>
      <span className={`${styles['vm-card__status']} ${styles[`vm-card__status--${status}`]}`}>
        {status}
      </span>
    </div>
  );
};
```

---

## 3. Модели Данных и Отношения

При генерации кода учитывай следующую структуру БД:
- **Workgroup**: `has_many :users`, `has_many :virtual_machines`, `has_many :virtual_machine_configs`.
- **User**: `belongs_to :workgroup`, `has_many :virtual_machines`.
- **VirtualMachineConfig**: `belongs_to :workgroup` (шаблоны ресурсов: CPU, RAM, Disk).
- **VirtualMachine**: `belongs_to :workgroup`, `belongs_to :user`, `belongs_to :virtual_machine_config`. Хранит `uuid` инстанса в libvirt и текущие метаданные.