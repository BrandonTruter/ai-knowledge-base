# State Management Standards for SOLID

> From [CodingRules.ai](https://codingrules.ai/rules/state-management-standards-for-solid)

**Tags:** SOLID

---

# State Management Standards for SOLID

This document outlines the coding standards for managing application state within SOLID applications. It covers approaches to state management, data flow, and reactivity, with a focus on the application of SOLID principles.

## 1. Introduction to State Management in SOLID

State management in SOLID applications is critical for ensuring predictability, maintainability, and testability. It involves handling application data in a structured manner to create reactive, data-driven UIs and robust backends. These standards aim to help developers build applications that are easy to understand, debug, and extend.

## 2. General Principles

### 2.1 Single Source of Truth

*   **Do This:** Define a single source of truth for each piece of state within your application. This source should be responsible for managing and updating the state.
*   **Don't Do This:** Avoid scattering state across multiple components or services, leading to inconsistencies and difficulties in debugging.

**Why:** Having a single source of truth ensures predictability and simplifies state management, reducing the risk of conflicting updates and race conditions.

### 2.2 Immutability

*   **Do This:** Treat state as immutable. When state changes, create a new version rather than modifying the existing one.
*   **Don't Do This:** Directly mutate state objects, especially in complex applications, as this can lead to unexpected side effects.

**Why:** Immutability simplifies debugging, enables time-travel debugging, and facilitates optimizations like memoization. It also helps in maintaining data integrity.

### 2.3 Explicit Data Flow

*   **Do This:** Establish a clear and unidirectional data flow. Components should react to state changes in a predictable manner.
*   **Don't Do This:** Allow bidirectional data binding or implicit data propagation, as this makes it difficult to trace the source of state changes.

**Why:** Explicit data flow makes it easier to understand and reason about the application's behavior, reducing the likelihood of bugs and making maintenance easier.

## 3. SOLID Principles and State Management

### 3.1 Single Responsibility Principle (SRP)

*   **Do This:** Ensure that each state management component (e.g., a state container, a reducer) has a single, well-defined responsibility.
*   **Don't Do This:** Create monolithic state managers that handle multiple unrelated aspects of the application state.

**Example:**
"""typescript
// Good: Each reducer handles a specific part of the state.
const userReducer = (state = initialUserState, action: UserAction) => { /* ... */ };
const productReducer = (state = initialProductState, action: ProductAction) => { /* ... */ };

// Bad: A single reducer handling both user and product state.
const appReducer = (state = initialState, action: AppAction) => { /* ... */ };
"""

**Why:** SRP promotes high cohesion and reduces the risk of unintended side effects when modifying state management logic.

### 3.2 Open/Closed Principle (OCP)

*   **Do This:** Design state management structures that are open for extension but closed for modification. Use patterns like reducers and middleware to add functionality without altering existing code.
*   **Don't Do This:** Modify core state management logic directly to accommodate new features.

**Example:**

"""typescript
// Good: Using middleware to add logging functionality.
const loggerMiddleware = (store) => (next) => (action) => {
  console.log('Dispatching:', action);
  let result = next(action);
  console.log('Next state:', store.getState());
  return result;
};

// Bad: Modifying existing reducers to add logging.
const userReducer = (state = initialState, action: UserAction) => {
  console.log('Action:', action); // Violates OCP
  // ... reducer logic ...
};

"""

**Why:** OCP facilitates the addition of new features and behaviors without introducing regression risks.

### 3.3 Liskov Substitution Principle (LSP)

*   **Do This:** Ensure that derived state management components (e.g., custom hooks, selectors) can be used in place of their base types without altering the correctness of the application.
*   **Don't Do This:** Create derived components that violate the contract of the base components, leading to unexpected behavior.

**Example:**

"""typescript
// Good: A custom hook that correctly substitutes a state manager hook
const useEnhancedUser = () => {
  const user = useUser(); // Assuming useUser is a base state management hook
  const enhancedUser = { ...user, fullName: "${user.firstName} ${user.lastName}" };
  return enhancedUser;
};

// Bad: A custom hook that alters the expected user state structure
const useBrokenUser = () => {
  const user = useUser();
  // Removes fields or modifies the structure unexpectedly
  const { firstName, ...rest } = user;
  return rest; // Violates LSP if components expect firstName
};
"""

**Why:** LSP ensures that inheritance and abstraction can be used safely, promoting code reusability and reducing the risk of runtime errors.

### 3.4 Interface Segregation Principle (ISP)

*   **Do This:** Define specific interfaces for state management components. Avoid forcing clients to depend on interfaces they do not use.
*   **Don't Do This:** Create large, general-purpose interfaces that contain methods or properties irrelevant to specific clients.

**Example:**

"""typescript
// Good: Segregated interfaces for different state management roles
interface ReadableState<T> {
  getState(): T;
}

interface WritableState<T> {
  setState(newState: T): void;
}

// Bad: A single monolithic interface
interface AppState<T> {
  getState(): T;
  setState(newState: T): void;
  subscribe(listener: () => void): void; // Unnecessary for some clients
}
"""

**Why:** ISP prevents unnecessary dependencies and minimizes the impact of interface changes on client code.

### 3.5 Dependency Inversion Principle (DIP)

*   **Do This:** Depend on abstractions (interfaces or abstract classes) rather than concrete implementations for state management. Configure state dependencies using dependency injection.
*   **Don't Do This:** Directly instantiate or depend on concrete state management classes within components.

**Example:**

"""typescript
// Good: Depending on an interface, allowing different state management implementations
interface StateManager<T> {
  getState(): T;
  setState(newState: T): void;
}

class ConcreteStateManager<T> implements StateManager<T> {
  // Implementation details
}

// Usage with Dependency Injection
class MyComponent {
  private stateManager: StateManager<MyStateType>;

  constructor(stateManager: StateManager<MyStateType>) {
    this.stateManager = stateManager;
  }
}

// Bad: Directly depending on a concrete class
class AnotherComponent {
  private stateManager: ConcreteStateManager<MyStateType>;

  constructor() {
    this.stateManager = new ConcreteStateManager<MyStateType>(); // Violates DIP
  }
}
"""

**Why:** DIP reduces coupling between components, making the system more flexible, testable, and maintainable.

## 4. State Management Patterns

### 4.1 Redux/Flux

*   **Do This:** Use centralized state containers with reducers to manage state transitions predictably. Implement middleware for handling side effects and asynchronous operations.

"""typescript
// Example with Redux Toolkit:
import { configureStore, createSlice } from '@reduxjs/toolkit';

const initialState = { value: 0 };

const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => { state.value += 1; },
    decrement: (state) => { state.value -= 1; },
    incrementByAmount: (state, action) => { state.value += action.payload; },
  },
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions;
export const selectCount = (state) => state.counter.value;

export const store = configureStore({
  reducer: {
    counter: counterSlice.reducer,
  },
});
"""

*   **Don't Do This:** Directly mutate the state within reducers. Avoid complex, nested state structures that are difficult to manage.

**Why:** Provides a predictable and traceable state management lifecycle.

### 4.2 Context API + Reducers (React)

*   **Do This:** Use "useReducer" with the Context API to manage local application state in a structured manner. Combine multiple contexts to manage different aspects of the application state.

"""typescript
// Example using Context API and useReducer:
import React, { createContext, useReducer, useContext } from 'react';

// Define actions
const ACTIONS = {
  INCREMENT: 'increment',
  DECREMENT: 'decrement',
};

// Reducer function
const reducer = (state, action) => {
  switch (action.type) {
    case ACTIONS.INCREMENT:
      return { count: state.count + 1 };
    case ACTIONS.DECREMENT:
      return { count: state.count - 1 };
    default:
      return state;
  }
};

// Initial state
const initialState = { count: 0 };

// Create context
const CounterContext = createContext();

// Provider component
const CounterProvider = ({ children }) => {
  const [state, dispatch] = useReducer(reducer, initialState);
  return (
    <CounterContext.Provider value={{ state, dispatch }}>
      {children}
    </CounterContext.Provider>
  );
};

// Custom hook to consume the context
const useCounter = () => {
  const context = useContext(CounterContext);
  if (!context) {
    throw new Error("useCounter must be used within a CounterProvider");
  }
  return context;
};

export { CounterProvider, useCounter, ACTIONS };
"""

*   **Don't Do This:** Overuse global context for managing local component state. Avoid direct manipulation of context values outside of reducers.

**Why:** Provides a simple and efficient way to manage state within React components.

### 4.3 MobX

*   **Do This:** Define observable state properties and use decorators to mark computed values and actions. Utilize "autorun" and "reaction" to react to state changes.

"""typescript
// Example with MobX:
import { makeObservable, observable, computed, action } from 'mobx';
import { observer } from 'mobx-react-lite';
import React from 'react';

class CounterStore {
  count = 0;

  constructor() {
    makeObservable(this, {
      count: observable,
      increment: action,
      decrement: action,
      doubleCount: computed
    });
  }

  increment() {
    this.count++;
  }

  decrement() {
    this.count--;
  }

  get doubleCount() {
    return this.count * 2;
  }
}

const counterStore = new CounterStore();

const CounterComponent = observer(() => (
  <div>
    <p>Count: {counterStore.count}</p>
    <p>Double Count: {counterStore.doubleCount}</p>
    <button onClick={() => counterStore.increment()}>Increment</button>
    <button onClick={() => counterStore.decrement()}>Decrement</button>
  </div>
));

export default CounterComponent;

"""

*   **Don't Do This:** Overuse "autorun" for complex logic. Directly modify observable properties outside of actions.

**Why:** Simplifies state management with automatic reactivity and efficient updates.

### 4.4 State Machines (XState)

*   **Do This:** Define state machines to manage complex, stateful logic. Use state transitions and guards to control state changes.

"""typescript
// Example with XState:
import { createMachine } from 'xstate';
import { useMachine } from '@xstate/react';
import React from 'react';

// Define the machine
const lightMachine = createMachine({
  id: 'light',
  initial: 'green',
  states: {
    green: { on: { TIMER: 'yellow' } },
    yellow: { on: { TIMER: 'red' } },
    red: { on: { TIMER: 'green' } }
  }
});

// Component using the machine
const TrafficLight = () => {
  const [state, send] = useMachine(lightMachine);

  React.useEffect(() => {
    const intervalId = setInterval(() => {
      send('TIMER');
    }, 1000);

    return () => clearInterval(intervalId);
  }, [send]);

  const getColor = () => {
    switch (state.value) {
      case 'green': return 'green';
      case 'yellow': return 'yellow';
      case 'red': return 'red';
      default: return 'gray';
    }
  };

  return (
    <div style={{
      width: '100px',
      height: '100px',
      borderRadius: '50%',
      backgroundColor: getColor()
    }} />
  );
};

export default TrafficLight;

"""

*   **Don't Do This:** Create overly complex state machines for simple logic. Fail to handle all possible state transitions.

**Why:** Provides a clear and structured way to manage complex state transitions and side effects.

## 5. Technology-Specific Considerations

### 5.1 React

*   **Good:** Utilize React Context for shared state. Employ "useReducer" or external state management libraries like Redux/MobX for complex applications. Utilize "useMemo" and "useCallback" to optimize performance when dealing with derived state or callbacks that depend on state.

    *   **Rationale:** Optimizes rendering and prevents unnecessary re-renders.

"""typescript
import React, { useState, useCallback, useMemo } from 'react';

function MyComponent({ data }) {
  const [count, setCount] = useState(0);

  // Memoize a value based on data
  const memoizedValue = useMemo(() => {
    console.log('Calculating...');
    return data.length * 2;
  }, [data]);

  // Memoize a callback function
  const increment = useCallback(() => {
    setCount(prevCount => prevCount + 1);
  }, []); // Empty dependency array as it doesn't depend on any props or state

  return (
    <div>
      <p>Count: {count}</p>
      <p>Memoized Value: {memoizedValue}</p>
      <button onClick={increment}>Increment</button>
    </div>
  );
}
"""

*   **Great:** Leverage "useContext" along with "useReducer" to create more scalable and maintainable state management solutions, especially for complex applications. This pattern allows for global state management without prop drilling, and keeps the state logic separate.

"""typescript
import React, { createContext, useReducer, useContext } from 'react';

// 1. Create a Context
const AppContext = createContext();

// 2. Define the initial state
const initialState = {
    theme: 'light',
    user: null,
};

// 3. Define the reducer function
const reducer = (state, action) => {
    switch (action.type) {
        case 'TOGGLE_THEME':
            return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' };
        case 'SET_USER':
            return { ...state, user: action.payload };
        default:
            return state;
    }
};

// 4. Create a custom provider
const AppProvider = ({ children }) => {
    const [state, dispatch] = useReducer(reducer, initialState);

    return (
        <AppContext.Provider value={{ state, dispatch }}>
            {children}
        </AppContext.Provider>
    );
};

// 5. Create a custom hook to use the context
const useAppContext = () => {
    return useContext(AppContext);
};

export { AppProvider, useAppContext };
"""

*   **Anti-pattern:** Prop Drilling - Passing state down through multiple layers of components that do not directly use the state.
*   **Alternative:**  Leverage React Context to make state available across the component tree, reducing prop drilling.

### 5.2 Angular

*   **Good:** Use RxJS observables for managing asynchronous data and creating reactive UIs. Implement services for managing shared state across components.

"""typescript
// Example with RxJS:
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private dataSubject = new BehaviorSubject<string>('Initial Data');
  public data$ = this.dataSubject.asObservable();

  updateData(newData: string) {
    this.dataSubject.next(newData);
  }
}
"""

*   **Great:** Utilize NgRx or Akita for managing complex application state in a predictable and scalable manner. Implement selectors to derive computed state efficiently.

"""typescript
// Example with NgRx:
import { createReducer, on } from '@ngrx/store';
import { increment, decrement } from './counter.actions';

export const initialState = 0;

const _counterReducer = createReducer(
  initialState,
  on(increment, (state) => state + 1),
  on(decrement, (state) => state - 1)
);

export function counterReducer(state, action) {
  return _counterReducer(state, action);
}
"""

*   **Anti-pattern:** Relying solely on "@Input" and "@Output" for state management in complex components leading to prop drilling.
*   **Alternative:** Opting for a service with RxJS BehaviorSubject for centralized state management and communication.

### 5.3 Vue

*   **Good:** Use Vuex store for centralized state management. Implement getters for deriving computed state.

    *   **Rationale:** Standardizes state management and improves component reusability.

"""javascript
// Example with Vuex:
import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    count: 0
  },
  mutations: {
    increment (state) {
      state.count++;
    },
    decrement (state) {
      state.count--;
    }
  },
  actions: {
    increment (context) {
      context.commit('increment');
    },
    decrement (context) {
      context.commit('decrement');
    }
  },
  getters: {
    doubleCount: state => state.count * 2
  }
});
"""

*   **Great:** Utilize the Composition API with "ref" and "reactive" for managing local component state, and Pinia for a more lightweight and type-safe alternative to Vuex. Pinia also benefits from a flatter structure than Vuex making debugging more straight forward.

    *   **Rationale:** Provides more flexible and composable state management options.

"""typescript
// Example with Vue Composition API AND Pinia
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const doubleCount = computed(() => count.value * 2)
  function increment() {
    count.value++
  }

  return { count, doubleCount, increment }
})
"""

*   **Anti-pattern:** Modifying state directly within components bypassing mutations in Vuex.
*   **Alternative:** Committing mutations to ensure state changes are tracked and predictable.

## 6. Performance Considerations

### 6.1 Memoization

*   **Do This:** Use memoization techniques (e.g., "useMemo" in React, selectors in Redux) to prevent unnecessary re-computations of derived state.
*   **Don't Do This:** Recompute derived state on every render, leading to performance bottlenecks.

**Why:** Reduces CPU usage and improves UI responsiveness.

### 6.2 Selective Updates

*   **Do This:** Update only the parts of the UI that depend on the changed state. Avoid re-rendering entire components unnecessarily.
*   **Don't Do This:** Force re-renders of large component trees on minor state changes.

**Why:** Minimizes DOM manipulations and improves rendering performance.

### 6.3 Data Normalization

*   **Do This:** Normalize data structures in the state to avoid deep nesting and duplication. Use IDs and references to link related entities.
*   **Don't Do This:** Store denormalized data in the state, leading to inefficient updates and complex data transformations.

**Why:** Simplifies state updates and reduces the amount of data that needs to be processed.

## 7. Security Considerations

### 7.1 State Persistence

*   **Do This:** Implement secure state persistence mechanisms (e.g., encrypted local storage, server-side storage) for sensitive data.
*   **Don't Do This:** Store sensitive data in plain text in the browser's local storage.

**Why:** Protects sensitive data from unauthorized access.

### 7.2 Input Validation

*   **Do This:** Validate user inputs before updating the application state. Prevent injection attacks and ensure data integrity.
*   **Don't Do This:** Trust user inputs blindly, potentially introducing vulnerabilities.

**Why:** Prevents malicious data from corrupting the application state or causing security breaches.

### 7.3 Access Control

*   **Do This:** Implement access control mechanisms to restrict state modifications based on user roles and permissions.
*   **Don't Do This:** Allow unauthorized users to modify critical application state.

**Why:** Ensures that only authorized users can make changes to the application state.

## 8. Testing Strategies

### 8.1 Unit Tests

*   **Do This:** Write unit tests for reducers, state machines, and other state management components. Verify that the correct state transitions occur in response to different actions.
*   **Don't Do This:** Neglect testing state management logic, leading to unpredictable behavior.

**Why:** Ensures that state management logic is correct and reliable.

### 8.2 Integration Tests

*   **Do This:** Write integration tests to verify that components interact correctly with the state management system. Ensure that state changes are reflected accurately in the UI.
*   **Don't Do This:** Rely solely on unit tests, potentially missing integration issues.

**Why:** Verifies the correct integration of components with the state management system.

### 8.3 End-to-End Tests

*   **Do This:** Write end-to-end tests to simulate user interactions and verify that the application state is updated correctly across the entire system.
*   **Don't Do This:** Skip end-to-end testing, potentially missing critical state management issues in the production environment.

**Why:** Ensures that state management works correctly from the user's perspective.

## 9. Conclusion

Adhering to these state management standards will result in more maintainable, performant, and secure SOLID applications. By understanding and applying the SOLID principles and following best practices, developers can build robust and scalable systems that meet the evolving needs of their users. Regularly reviewing and updating these standards is essential to keep pace with the latest advancements in state management technologies and best practices.
