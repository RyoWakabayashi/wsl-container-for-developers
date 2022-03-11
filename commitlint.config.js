module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'subject-case': [
      0,
      'always',
      []
    ],
    'subject-max-length': [
      2,
      'always',
      50
    ],
    'type-case': [
      2,
      'always',
      'lower-case'
    ],
    'body-max-line-length': [
      2,
      'always',
      72
    ],
    'footer-max-line-length': [
      2,
      'always',
      72
    ]
  }
}
