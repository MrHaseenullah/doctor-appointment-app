# Contributing to Doctor Appointment App

Thank you for your interest in contributing to the Doctor Appointment App! This document provides guidelines and information for contributors.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Contributing Process](#contributing-process)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Pull Request Process](#pull-request-process)
8. [Issue Reporting](#issue-reporting)

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow:

- Be respectful and inclusive
- Use welcoming and inclusive language
- Be collaborative and constructive
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.0.0 or higher
- Git for version control
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)
- Firebase account for backend services

### Development Setup

1. **Fork the Repository**
   ```bash
   # Fork the repo on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/doctor-appointment-app.git
   cd doctor-appointment-app
   ```

2. **Set Up Upstream Remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/doctor-appointment-app.git
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Set Up Firebase**
   - Create a Firebase project
   - Add your configuration files
   - Enable Authentication and Firestore

5. **Run the App**
   ```bash
   flutter run
   ```

## Contributing Process

### 1. Choose an Issue
- Look for issues labeled `good first issue` for beginners
- Check if the issue is already assigned
- Comment on the issue to express interest

### 2. Create a Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Make Changes
- Write clean, readable code
- Follow the coding standards
- Add tests for new features
- Update documentation if needed

### 4. Test Your Changes
```bash
# Run tests
flutter test

# Check formatting
dart format .

# Analyze code
flutter analyze
```

### 5. Commit Your Changes
```bash
git add .
git commit -m "type(scope): description"
```

#### Commit Message Format
```
type(scope): description

Types:
- feat: new feature
- fix: bug fix
- docs: documentation changes
- style: formatting changes
- refactor: code refactoring
- test: adding tests
- chore: maintenance tasks

Examples:
- feat(auth): add password reset functionality
- fix(booking): resolve appointment time conflict
- docs(readme): update installation instructions
```

### 6. Push and Create Pull Request
```bash
git push origin your-branch-name
```

Then create a pull request on GitHub.

## Coding Standards

### Dart/Flutter Guidelines
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

### File Organization
```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

### Code Examples

#### Good Practice
```dart
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Books an appointment for the given patient and doctor
  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
  }) async {
    try {
      // Implementation
      return true;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      return false;
    }
  }
}
```

#### Widget Structure
```dart
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? const CircularProgressIndicator()
        : Text(text),
    );
  }
}
```

## Testing Guidelines

### Unit Tests
- Test business logic in services
- Test utility functions
- Aim for 90%+ coverage

### Widget Tests
- Test UI components
- Test user interactions
- Test form validation

### Integration Tests
- Test complete user flows
- Test Firebase integration
- Test cross-platform compatibility

### Test Structure
```dart
void main() {
  group('AuthService', () {
    late AuthService authService;
    
    setUp(() {
      authService = AuthService();
    });
    
    test('should sign in user with valid credentials', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // Act
      final result = await authService.signIn(email, password);
      
      // Assert
      expect(result, isTrue);
    });
  });
}
```

## Pull Request Process

### Before Submitting
- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] No merge conflicts
- [ ] Commit messages are clear

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests pass
- [ ] Documentation updated
```

### Review Process
1. Automated checks must pass
2. At least one maintainer review required
3. Address feedback promptly
4. Squash commits if requested

## Issue Reporting

### Bug Reports
Use the bug report template:
```markdown
**Describe the bug**
A clear description of the bug

**To Reproduce**
Steps to reproduce the behavior

**Expected behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment:**
- Device: [e.g. iPhone 12, Pixel 5]
- OS: [e.g. iOS 15, Android 12]
- App Version: [e.g. 1.0.0]
```

### Feature Requests
Use the feature request template:
```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of desired feature

**Additional context**
Any other context or screenshots
```

## Getting Help

- **Documentation**: Check the README.md first
- **Discussions**: Use GitHub Discussions for questions
- **Issues**: Create an issue for bugs or feature requests
- **Discord**: Join our community Discord server

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Annual contributor appreciation

Thank you for contributing to the Doctor Appointment App! 🚀
