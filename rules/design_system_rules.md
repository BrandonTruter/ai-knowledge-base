# Design System Rules for Figma Integration

This document provides comprehensive rules for integrating Figma designs into the Omnichannel application using the Model Context Protocol (MCP). It covers token definitions, component architecture, styling approaches, and asset management patterns.

## 1. Token Definitions

### 1.1 Token Structure

The application uses a dual-token system:

#### Primitive Tokens (SCSS-based)
**Location:** `omni/engines/conversational/app/javascript/conversational/ncino-ui/tokens/scss/primitive.tokens.scss`

Primitive tokens define base design values using CSS custom properties:

```scss
:root {
  // Color tokens
  --color-black-100: #000000;
  --color-neutral-80: #040404;
  --color-brand-50: #0a2033;
  --color-brand-30: #11395b;

  // Spacing tokens
  --spacing-1: 0.125rem;
  --spacing-2: 0.25rem;
  --spacing-4: 1rem;
  --spacing-7: 2rem;

  // Typography tokens
  --text-family-headings: 'nCino Avenir', 'Lexend Deca', sans-serif;
}
```

#### Semantic Tokens (SCSS-based)
**Location:** `omni/engines/conversational/app/javascript/conversational/ncino-ui/tokens/scss/semantic.tokens.scss`

Semantic tokens map primitive tokens to contextual usage:

```scss
:root {
  --color-text-primary-base: var(--color-neutral-70, #1F1F1F);
  --color-text-secondary: var(--color-neutral-50, #6D6D6D);
  --color-border-primary: var(--color-neutral-50, #6D6D6D);
  --color-surface-primary: var(--color-neutral-0, #FFFFFF);
  --color-surface-interactive-primary: var(--color-brand-40, #0E304D);
}
```

#### TypeScript Token Exports
**Location:** `omni/engines/conversational/app/javascript/conversational/ncino-ui/tokens/index.ts`

Tokens are auto-generated from SCSS files into TypeScript for use in React components:

```typescript
import { colors, typography, spacing, radius, shadows, sizing } from './tokens';

// Usage in React components
const theme = {
  color: colors.brand[30],
  spacing: spacing[4],
  typography: typography.heading.h1
};
```

**Regeneration:** Run `npm run tokens:generate` to regenerate TypeScript tokens from SCSS sources.

### 1.2 Legacy Token System (Vue/Vuetify)

**Location:** `omni/app/javascript/assets/css/snui/_snColorVariables.module.scss`

Legacy Vue components use SCSS variables and CSS classes:

```scss
// SCSS Variables
$sn-primary-01: #6D6D6D;
$sn-primary-03: #1F1F1F;
$sn-brand-03: #11395B;

// CSS Classes
.sn-text-primary { color: $sn-primary; }
.sn-background-brand { background-color: $sn-brand; }
```

**Usage in Vue components:**
```vue
<template>
  <div class="sn-text-primary sn-background-brand">
    Content
  </div>
</template>
```

### 1.3 Token Naming Conventions

- **Colors:** `--color-{name}-{shade}` (e.g., `--color-brand-30`, `--color-neutral-50`)
- **Spacing:** `--spacing-{size}` (e.g., `--spacing-4`, `--spacing-7`)
- **Typography:** `--text-{property}` (e.g., `--text-family-headings`)
- **Semantic:** `--color-{category}-{usage}` (e.g., `--color-text-primary-base`, `--color-border-primary`)

### 1.4 Color Palette Structure

The design system uses a systematic color scale:

- **Neutral:** 0-80 scale (light to dark)
- **Brand:** 0-50 scale (light to dark)
- **Semantic Colors:** green (success), red (error), orange (caution), purple, blue, aqua
- **Shade Convention:** Lower numbers = lighter, higher numbers = darker

## 2. Component Library

### 2.1 Component Architecture

The application uses a multi-framework approach:

#### Vue.js Components (Primary)
**Location:** `omni/app/javascript/components/`

Components are organized by feature area:
- `homehub/` - Main dashboard components
- `common/` - Shared utility components
- `customForms/` - Form builder components
- `adminPack/` - Admin interface components
- `loanOfficerApp/` - Loan officer interface

**Component Structure:**
```vue
<template>
  <!-- Template content -->
</template>

<script>
export default {
  name: 'ComponentName',
  props: { /* ... */ },
  data() { /* ... */ },
  computed: { /* ... */ },
  methods: { /* ... */ }
}
</script>

<style lang="scss" scoped>
@import '~/assets/css/snui';
// Component-specific styles
</style>
```

#### React Components (Conversational Engine)
**Location:** `omni/engines/conversational/app/javascript/conversational/`

React components use TypeScript and Material-UI:

```typescript
import React from 'react';
import { Button } from '@mui/material';
import { colors, spacing } from '../ncino-ui/tokens';

export const MyComponent: React.FC<Props> = ({ ... }) => {
  return (
    <Button sx={{ color: colors.brand[30], margin: spacing[4] }}>
      Click me
    </Button>
  );
};
```

#### SNUI Component Library
**Location:** Imported from `@ncino/snui` package

Pre-built components available across the application:

```javascript
import {
  snBtn,
  snCard,
  snTextField,
  snSelect,
  snModal,
  // ... many more
} from '@ncino/snui';
```

**Registration in Vue:**
```javascript
// In pack files (e.g., myHome.js)
Vue.component('snBtn', snBtn);
Vue.component('snCard', snCard);
```

### 2.2 Component Naming Conventions

- **Vue Components:** PascalCase (e.g., `ApplicationDashboard.vue`)
- **React Components:** PascalCase (e.g., `ChatPage.tsx`)
- **SNUI Components:** kebab-case with `sn-` prefix (e.g., `sn-btn`, `sn-card`)
- **File Names:** Match component name (e.g., `MyComponent.vue`)

### 2.3 Component Documentation

- **Storybook:** Available at `npm run storybook` (port 6006)
- **Component Stories:** Located in component directories with `.stories.js` extension
- **TypeScript Types:** Defined in component files or separate `.ts` files

## 3. Frameworks & Libraries

### 3.1 Frontend Frameworks

#### Vue.js 2.6.x (Primary)
- **Location:** Main application and most engines
- **State Management:** Vuex
- **Router:** Vue Router
- **UI Framework:** Vuetify 2.x

#### React (Conversational Engine)
- **Location:** `omni/engines/conversational/`
- **State Management:** React Context API, TanStack Store
- **UI Framework:** Material-UI (MUI) v7
- **Router:** React Router

### 3.2 Styling Libraries

#### SCSS/Sass
- **Primary styling language** for Vue components
- **Location:** `omni/app/javascript/assets/css/`
- **Global imports:** Available via `@import '~/assets/css/snui';`
- **Variables:** Defined in `_snColorVariables.module.scss` and `_snTypographyVariables.scss`

#### CSS Modules
- **Usage:** For scoped styles in React components
- **Pattern:** `styles.module.css` files

#### Material-UI (MUI) Theme
**Location:** `omni/engines/conversational/app/javascript/conversational/ncino-ui/themes/muiTheme.ts`

MUI theme extends design tokens:

```typescript
import { createTheme } from '@mui/material/styles';
import { colors, typography, spacing } from '../tokens';

export const muiTheme = createTheme({
  palette: {
    primary: { main: colors.brand[30] },
    // ...
  },
  typography: {
    // Uses typography tokens
  }
});
```

### 3.3 Build System

#### Webpack
**Configuration:** `omni/webpack.config.js`

- **Entry Points:** Multiple packs (adminPack, myHome, conversationalPack, etc.)
- **Asset Handling:** Images, fonts, SVGs via asset rules
- **Loaders:** Vue, Babel, SCSS, GraphQL, custom `.snvg` loader
- **Output:** `app/assets/builds/`

#### Asset Processing
- **Images:** `jpg|jpeg|png|gif|tiff|ico|svg` → Webpack asset loader
- **Fonts:** `eot|otf|ttf|woff|woff2` → Webpack asset loader
- **SVG Components:** `.snvg` files → `vue-svg-loader` with SVGO optimization

### 3.4 Development Tools

- **Linting:** ESLint for JavaScript/Vue, Rubocop for Ruby
- **Formatting:** Prettier
- **Testing:** Jest (JavaScript), RSpec (Ruby)
- **Storybook:** Component development and documentation

## 4. Asset Management

### 4.1 Asset Locations

#### Static Assets
- **Images:** `omni/app/javascript/assets/images/`
- **Fonts:**
  - Main: `omni/app/javascript/assets/fonts/`
  - Conversational: `omni/engines/conversational/app/javascript/conversational/assets/fonts/`
- **SVG Icons:** `omni/app/javascript/assets/images/` (as `.snvg` files)

#### Build Output
- **Compiled Assets:** `omni/app/assets/builds/`
- **Rails Asset Pipeline:** `omni/app/assets/`

### 4.2 Asset Import Patterns

#### Vue Components
```vue
<script>
// Direct import
import logo from '~/assets/images/logo.svg';
import illustration from '~/assets/images/illustration.snvg';

export default {
  data() {
    return {
      logoImage: logo
    }
  },
  components: {
    Illustration: illustration
  }
}
</script>

<template>
  <img :src="logoImage" alt="Logo" />
  <Illustration />
</template>
```

#### React Components
```typescript
import logo from '../assets/icons/Logo.svg';
import { SvgIcon } from '@mui/material';

// Usage
<img src={logo} alt="Logo" />
```

### 4.3 SVG Handling

#### Custom SVG Components (`.snvg` files)
**Location:** `omni/app/javascript/assets/images/*.snvg`

SVG files with `.snvg` extension are processed as Vue components:

```vue
<script>
import Balloons from '~/assets/images/balloons.snvg';

export default {
  components: {
    Balloons
  }
}
</script>

<template>
  <Balloons />
</template>
```

**Webpack Configuration:**
```javascript
const snvgLoader = {
  test: /\.snvg$/,
  use: [
    'babel-loader',
    {
      loader: 'vue-svg-loader',
      options: {
        svgo: {
          plugins: [{ prefixIds: true }]
        }
      }
    }
  ]
};
```

### 4.4 Asset Optimization

- **SVGO:** Automatic SVG optimization via `vue-svg-loader`
- **Webpack:** Automatic asset optimization and hashing
- **Rails Asset Pipeline:** Asset precompilation and fingerprinting

### 4.5 CDN Configuration

- **Font Loading:** Google Fonts via `@import` in SCSS
- **Custom Fonts:** Self-hosted in `assets/fonts/` directories
- **Image CDN:** Configured via Rails asset pipeline (see `config/initializers/assets.rb`)

## 5. Icon System

### 5.1 Icon Libraries

#### SimpleNexus Icon Font
**Location:** `omni/app/javascript/util/icons.js`

Icon font system using IcoMoon selection:

```javascript
import icons from '~/util/icons.js';

// Usage in Vuetify
const vuetifyConfig = {
  icons: {
    values: {
      ...icons, // 'sn-icon-{name}' format
    }
  }
};
```

**Usage:**
```vue
<template>
  <v-icon>sn-icon-check</v-icon>
</template>
```

#### SNUI SVG Icons
**Location:** Imported from `@ncino/snui` package

```javascript
import { svgIcons } from '@ncino/snui';

// Registered in Vuetify config
const Icons = Object.keys(svgIcons).reduce((dict, iconName) => ({
  ...dict,
  [`${iconName}`]: { component: svgIcons[iconName] }
}), {});
```

#### React Icon Components
**Location:** `omni/engines/conversational/app/javascript/conversational/ncino-ui/Icon/`

TypeScript icon registry system:

```typescript
// Icon.tsx
export type IconName = 'apartment' | 'pencil-paper' | 'sparkle' | 'arrow-up';

const ICON_REGISTRY: Record<IconName, React.ComponentType> = {
  apartment: ApartmentIcon,
  'pencil-paper': PencilPaperIcon,
  sparkle: SparkleIcon,
  'arrow-up': ArrowUpIcon
};

// Usage
<Icon iconName="apartment" size={24} color={colors.brand[30]} />
```

#### nCino Web Components Icons
**Location:** `@ncino/web-components/gator`

Web component icons:

```typescript
// NcinoIcon.tsx
<ngc-icon
  name="icon-name"
  size={24}
  type="default"
/>
```

### 5.2 Icon Naming Conventions

- **SimpleNexus Icons:** `sn-icon-{name}` (kebab-case)
- **SNUI Icons:** Component names (camelCase)
- **React Icons:** TypeScript enum/union types (kebab-case or camelCase)
- **Custom Icons:** Match file name (PascalCase for components)

### 5.3 Icon Usage Patterns

#### Vue/Vuetify
```vue
<template>
  <!-- Icon font -->
  <v-icon>sn-icon-check</v-icon>

  <!-- SVG icon -->
  <v-icon>{{ svgIcons.checkIcon }}</v-icon>
</template>
```

#### React/MUI
```typescript
import { Icon } from '../ncino-ui/Icon';
import { NcinoIcon } from '../ncino-ui/Icon/NcinoIcon';

// Custom icon component
<Icon iconName="apartment" size={24} />

// Web component icon
<NcinoIcon name="check" size={24} />
```

## 6. Styling Approach

### 6.1 CSS Methodology

#### Scoped Styles (Vue)
```vue
<style lang="scss" scoped>
@import '~/assets/css/snui';

.component-class {
  // Scoped to this component
}
</style>
```

#### CSS Modules (React)
```typescript
import styles from './Component.module.css';

<div className={styles.container}>
```

#### Global Styles
**Location:** `omni/app/javascript/assets/css/snui/`

Global SCSS files:
- `_snColors.scss` - Color utility classes
- `_snTypography.scss` - Typography mixins and classes
- `_snColorVariables.module.scss` - Color variables
- `index.scss` - Main entry point

### 6.2 Responsive Design

#### Breakpoints (Vuetify)
**Location:** `omni/app/javascript/util/vuetify.js`

```javascript
breakpoint: {
  thresholds: {
    xs: 320,
    sm: 540,
    md: 990,
    lg: 1280
  }
}
```

#### Media Queries (SCSS)
**Pattern:** Used in typography mixins and component styles

```scss
@mixin sn-h1 {
  @media screen and (max-width: $medium-screen-size) {
    font-size: 1.75rem !important;
  }

  @media screen and (min-width: $medium-screen-size + 1) {
    font-size: 2.5rem !important;
  }
}
```

#### Responsive Utilities
- **Vuetify:** `xs`, `sm`, `md`, `lg` breakpoint props
- **CSS Grid:** Responsive grid containers (see `LoanSummary.vue` example)
- **Flexbox:** Vuetify layout system

### 6.3 Typography System

#### Typography Mixins
**Location:** `omni/app/javascript/assets/css/snui/_snTypography.scss`

Available mixins:
- `sn-display-1`, `sn-display-2`
- `sn-h1` through `sn-h5`
- `sn-subtitle-1`, `sn-subtitle-2`
- `sn-body-1`, `sn-body-2`
- `sn-caption`, `sn-caption-01`
- `sn-btn`

**Usage:**
```vue
<style lang="scss" scoped>
@import '~/assets/css/snui';

.heading {
  @include sn-h1;
}
</style>
```

#### Typography Classes
```vue
<template>
  <h1 class="sn-h1">Heading</h1>
  <p class="sn-body-1">Body text</p>
  <span class="sn-caption">Caption</span>
</template>
```

#### Font Families
- **Primary:** Open Sans (400, 600, 700)
- **Secondary:** Source Serif Pro (700, 900)
- **Headings:** nCino Avenir, Lexend Deca (conversational engine)

### 6.4 Spacing System

#### Spacing Tokens
**Values:** `2px, 4px, 8px, 16px, 24px, 32px` (spacing-1 through spacing-7)

**Usage:**
```typescript
// React
import { spacing } from '../tokens';
<div style={{ margin: spacing[4] }}> // 16px
```

```scss
// SCSS
.component {
  padding: var(--spacing-4); // 1rem (16px)
  margin: var(--spacing-6); // 1.5rem (24px)
}
```

#### Vuetify Spacing
- **Utility Classes:** `pa-{n}`, `ma-{n}`, `px-{n}`, `py-{n}`, etc.
- **Spacing Scale:** 4px increments (e.g., `pa-4` = 16px padding)

## 7. Project Structure

### 7.1 Directory Organization

```
omni/
├── app/
│   ├── javascript/
│   │   ├── assets/
│   │   │   ├── css/
│   │   │   │   └── snui/          # Global styles
│   │   │   ├── images/             # Static images
│   │   │   └── fonts/              # Custom fonts
│   │   ├── components/             # Vue components
│   │   │   ├── common/             # Shared components
│   │   │   ├── homehub/            # Dashboard components
│   │   │   └── [feature]/          # Feature-specific components
│   │   ├── packs/                  # Webpack entry points
│   │   ├── services/               # API services
│   │   ├── store/                  # Vuex stores
│   │   └── util/                   # Utilities
│   └── assets/
│       └── builds/                 # Webpack output
├── engines/
│   └── conversational/
│       └── app/
│           └── javascript/
│               └── conversational/
│                   ├── ncino-ui/   # React component library
│                   │   ├── tokens/ # Design tokens
│                   │   ├── themes/ # MUI theme
│                   │   └── Icon/   # Icon components
│                   └── components/ # React components
└── webpack.config.js              # Webpack configuration
```

### 7.2 Feature Organization

Components are organized by:
1. **Feature Area:** `homehub/`, `adminPack/`, `loanOfficerApp/`
2. **Component Type:** `common/` for shared components
3. **Engine Boundaries:** Engine-specific components in engine directories

### 7.3 Import Aliases

**Webpack Aliases:**
- `~` → `app/javascript/`
- `assets` → `app/javascript/assets/`
- `~business` → `engines/business/app/javascript/business/`
- `~conversational` → `engines/conversational/app/javascript/conversational/`

**Usage:**
```javascript
import Component from '~/components/MyComponent.vue';
import styles from '~/assets/css/snui';
import icon from 'assets/images/icon.svg';
```

## 8. Figma Integration Guidelines

### 8.1 Design Token Mapping

When extracting design tokens from Figma:

1. **Colors:** Map Figma color styles to semantic token names
   - Use semantic naming (e.g., `--color-text-primary-base` not `--color-gray-700`)
   - Maintain shade consistency (0-80 scale)

2. **Spacing:** Convert Figma spacing to token values
   - Round to nearest token value (2px, 4px, 8px, 16px, 24px, 32px)
   - Use spacing tokens, not arbitrary values

3. **Typography:** Map Figma text styles to typography mixins
   - Match to existing mixins (`sn-h1`, `sn-body-1`, etc.)
   - Create new mixins only if no match exists

### 8.2 Component Implementation

When implementing Figma designs:

1. **Use Existing Components:** Check SNUI library first
2. **Component Structure:** Follow Vue/React patterns above
3. **Styling:** Use design tokens, not hardcoded values
4. **Responsive:** Implement breakpoints using Vuetify or media queries
5. **Accessibility:** Follow WCAG guidelines (SNUI components are pre-compliant)

### 8.3 Asset Extraction

1. **Images:** Export as SVG when possible, use `.snvg` for Vue components
2. **Icons:** Add to appropriate icon system (font, SVG registry, or component)
3. **Fonts:** Use existing font families; add new fonts only if required
4. **Optimization:** Run SVGs through SVGO, optimize images before commit

### 8.4 Design System Sync

1. **Token Updates:** Update SCSS token files, then regenerate TypeScript tokens
2. **Component Updates:** Update SNUI components or create engine-specific variants
3. **Documentation:** Update Storybook stories for new components
4. **Testing:** Verify responsive behavior and accessibility

## 9. Best Practices

### 9.1 Token Usage

✅ **DO:**
- Use semantic tokens for component styling
- Reference tokens via CSS custom properties or TypeScript imports
- Maintain token consistency across components

❌ **DON'T:**
- Hardcode color values or spacing
- Create new tokens without design system approval
- Mix token systems (use React tokens in React, Vue tokens in Vue)

### 9.2 Component Development

✅ **DO:**
- Use scoped styles in Vue components
- Follow existing component patterns
- Test responsive behavior
- Document component props and usage

❌ **DON'T:**
- Create global styles without approval
- Duplicate existing component functionality
- Mix Vue and React patterns in same component

### 9.3 Asset Management

✅ **DO:**
- Use `.snvg` for SVG components in Vue
- Optimize images before committing
- Follow naming conventions
- Use asset aliases for imports

❌ **DON'T:**
- Commit unoptimized assets
- Use absolute paths for assets
- Duplicate assets across directories

## 10. Troubleshooting

### Common Issues

1. **Tokens not updating:** Run `npm run tokens:generate`
2. **Styles not applying:** Check scoped attribute and import paths
3. **Icons not showing:** Verify icon registration in pack files
4. **Assets not loading:** Check webpack build output and Rails asset pipeline

### Debugging Tools

- **Webpack Dev Server:** `yarn serve` for frontend hot reload
- **Rails Server:** `bundle exec rails s` for backend
- **Storybook:** `npm run storybook` for component development
- **Browser DevTools:** Inspect computed styles and token values

---

**Last Updated:** Generated from codebase analysis
**Maintained By:** Development Team
**Related Documentation:**
- [CLAUDE.md](/omni/CLAUDE.md) - Project overview and conventions
- [README.md](/omni/README.md) - Setup and development guide

