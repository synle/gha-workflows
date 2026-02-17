## curl -s -- https://raw.githubusercontent.com/synle/gha-workflows/refs/heads/main/setup-repo-node.js | bash -s --
# Initialize configuration files
echo "* text=auto eol=lf" > .gitattributes

# prettier
node -e """
const file = '.prettierignore';
const additions = [
  'build',
  '*.bundle.*',
  '*.min.*',
  '.build',
  'coverage',
  'dist',
  'node_modules',
];
const fs = require('fs');

let existing = '';
if (fs.existsSync(file)) {
  existing = fs.readFileSync(file, 'utf8');
}

const lines = [...existing.split(/\r?\n/), ...additions]
  .map(l => l.trim())
  .filter(Boolean);

const unique = [...new Set(lines)];
fs.writeFileSync(file, unique.join('\n') + '\n');
console.log('✅ ' + file + ' consolidated and cleaned.');
"""

# gitignore
node -e """
const file = '.gitignore';
const additions = [
  '*.LICENSE.txt', 
  '*.rej', 
  '*storybook.log', 
  '.cache', 
  '.claude', 
  '.DS_Store', 
  '.env', 
  '.npmrc', 
  '.nyc_output', 
  '.prettier-cache', 
  '.vs-code', 
  'build', 
  'coverage', 
  'DEBUG', 
  'dist', 
  'Error', 
  'node_modules', 
  'npm-debug.log*', 
  'package-lock.json', 
  'public/vs', 
  'upload', 
  'yarn-debug.log*', 
  'yarn-error.log*', 
  'yarn.lock',
];
const fs = require('fs');
let existing = '';
if (fs.existsSync(file)) {
  existing = fs.readFileSync(file, 'utf8');
}

const lines = [...existing.split(/\r?\n/), ...additions]
  .map(l => l.trim())
  .filter(Boolean);

const unique = [...new Set(lines)];
fs.writeFileSync(file, unique.join('\n') + '\n');
console.log('✅ ' + file + ' consolidated and cleaned.');
"""

# Update package.json scripts using Node (No jq required)
node -e """
const fs = require('fs');
const file = 'package.json';
if (fs.existsSync(file)) {
  const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
  pkg.scripts = pkg.scripts || {};
  pkg.scripts.format = \"prettier --write --ignore-unknown --cache '**/*.{js,jsx,ts,tsx,mjs,cjs,json,html,css,scss,less,md,yml,yaml,graphql,vue,xml}'\";
  fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + '\n');
  console.log('✅ package.json format script updated.');
} else {
  console.log('❌ Error: package.json not found.');
}
"""
