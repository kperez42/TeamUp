# TeamUp iOS Test Infrastructure - Complete Overview

## EXECUTIVE SUMMARY

Your TeamUp gaming social app has a **comprehensive test infrastructure** with:

- **25 test files** organized by functionality
- **200+ unit tests** covering critical paths
- **10+ mock service implementations** ready for dependency injection
- **Repository protocols** defined but not fully utilized
- **Integration test base** with Firebase Emulator support
- **5 ViewModels with tests** for critical user flows

### Key Findings

✅ **Strengths:**
- Excellent test data builders (TestFixtures.swift)
- Comprehensive mock implementations with call tracking
- Firebase Emulator integration setup
- Clear test organization by service/feature
- Support for async/await testing
- Protocol definitions exist (though underutilized)

⚠️ **Improvements Needed:**
- Singletons create tight coupling (not fully testable)
- ViewModels don't use dependency injection
- Repository protocols defined but not implemented
- Coverage gaps in E2E flows (premium, referral, offline)
- Some services lack protocol equivalents

---

## TEST FILE LOCATIONS (Absolute Paths)

### Service Tests
- `/home/user/TeamUp/TeamUpTests/AuthServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/UserServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/MatchServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/MessageServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/SwipeServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/ContentModeratorTests.swift`
- `/home/user/TeamUp/TeamUpTests/InputSanitizerTests.swift`
- `/home/user/TeamUp/TeamUpTests/ReferralManagerTests.swift`
- `/home/user/TeamUp/TeamUpTests/StoreManagerTests.swift`
- `/home/user/TeamUp/TeamUpTests/RateLimiterTests.swift`
- `/home/user/TeamUp/TeamUpTests/BatchOperationManagerTests.swift`

### ViewModel Tests
- `/home/user/TeamUp/TeamUpTests/DiscoverViewModelTests.swift`
- `/home/user/TeamUp/TeamUpTests/ChatViewModelTests.swift`
- `/home/user/TeamUp/TeamUpTests/ProfileEditViewModelTests.swift`
- `/home/user/TeamUp/TeamUpTests/SavedProfilesViewModelTests.swift`
- `/home/user/TeamUp/TeamUpTests/LikeActivityViewModelTests.swift`

### Integration & Performance Tests
- `/home/user/TeamUp/TeamUpTests/EndToEndFlowTests.swift`
- `/home/user/TeamUp/TeamUpTests/IntegrationTestBase.swift`
- `/home/user/TeamUp/TeamUpTests/PerformanceBenchmarkTests.swift`
- `/home/user/TeamUp/TeamUpTests/NetworkFailureTests.swift`
- `/home/user/TeamUp/TeamUpTests/RaceConditionTests.swift`
- `/home/user/TeamUp/TeamUpTests/MessagePaginationTests.swift`

### Test Infrastructure
- `/home/user/TeamUp/TeamUpTests/MockServices.swift` (10+ mocks)
- `/home/user/TeamUp/TeamUpTests/TestFixtures.swift` (data builders)
- `/home/user/TeamUp/TeamUpTests/TestData.swift`

---

## DATA SERVICES/REPOSITORIES NEEDING TESTS

### Critical Services (High Priority)
1. **AuthService** - `/home/user/TeamUp/TeamUp/AuthService.swift`
   - Tested: ✅ Yes (AuthServiceTests.swift)
   - Mock: ✅ Yes (MockAuthService)
   - Protocol: ✅ Yes (AuthServiceProtocol)

2. **UserService** - `/home/user/TeamUp/TeamUp/UserService.swift`
   - Tested: ✅ Yes (UserServiceTests.swift)
   - Mock: ✅ Yes (MockUserService)
   - Protocol: ✅ Yes (UserServiceProtocol)

3. **MatchService** - `/home/user/TeamUp/TeamUp/MatchService.swift`
   - Tested: ✅ Yes (MatchServiceTests.swift)
   - Mock: ✅ Yes (MockMatchService)
   - Protocol: ✅ Yes (MatchServiceProtocol)

4. **MessageService** - `/home/user/TeamUp/TeamUp/MessageService.swift`
   - Tested: ✅ Yes (MessageServiceTests.swift)
   - Mock: ✅ Yes (MockMessageService)
   - Protocol: ✅ Yes (MessageServiceProtocol)

5. **SwipeService** - `/home/user/TeamUp/TeamUp/SwipeService.swift`
   - Tested: ✅ Yes (SwipeServiceTests.swift)
   - Mock: ✅ Yes (MockSwipeService)
   - Protocol: ✅ Yes (SwipeServiceProtocol)

### Important Services (Medium Priority)
- **ContentModerator** - `/home/user/TeamUp/TeamUp/ContentModerator.swift`
  - Has protocol: ✅ ContentModeratorProtocol
  - Has mock: ✅ MockContentModerator
  
- **NotificationService** - `/home/user/TeamUp/TeamUp/NotificationService.swift`
  - Has protocol: ✅ NotificationServiceProtocol
  - Has mock: ✅ MockNotificationService

- **StoreManager** - `/home/user/TeamUp/TeamUp/StoreManager.swift`
  - Tested: ✅ Yes
  - Has mock: ❓ Partial

- **OfflineManager** - `/home/user/TeamUp/TeamUp/OfflineManager.swift`
  - Tested: ⚠️ Limited
  - Offline E2E flows need coverage

### Infrastructure Services (Lower Priority)
- **NetworkManager** - Has mock (MockNetworkManager)
- **BackendAPIService** - Has protocol (BackendAPIServiceProtocol)
- **ReferralManager** - Tested, needs E2E coverage
- **CircuitBreaker, SmartRetryManager, QueryCache** - Infrastructure, limited testing

---

## VIEWMODELS REQUIRING TESTS

### Implemented & Tested
1. **DiscoverViewModel** - `/home/user/TeamUp/TeamUp/DiscoverViewModel.swift`
   - Tests: `/home/user/TeamUp/TeamUpTests/DiscoverViewModelTests.swift`
   - Key flows: loadUsers(), handleLike(), handlePass(), handleSuperLike()
   - Dependencies: UserService, SwipeService, MatchService, AuthService

2. **ChatViewModel** - `/home/user/TeamUp/TeamUp/ChatViewModel.swift`
   - Tests: `/home/user/TeamUp/TeamUpTests/ChatViewModelTests.swift`
   - Key flows: loadMatches(), loadMessages(), sendMessage()
   - Dependencies: MatchService, MessageService

3. **ProfileEditViewModel** - `/home/user/TeamUp/TeamUp/ProfileEditViewModel.swift`
   - Tests: `/home/user/TeamUp/TeamUpTests/ProfileEditViewModelTests.swift`
   - Key flows: uploadProfileImage(), updateProfile()

4. **SavedProfilesViewModel** - Uses SavedProfilesView.swift
   - Tests: Available (SavedProfilesViewModelTests.swift)

5. **LikeActivityViewModel** - Uses LikeActivityView.swift
   - Tests: Available (LikeActivityViewModelTests.swift)

### Not Yet Covered (ViewModel Tests Needed)
- Profile viewing ViewModel
- Matches/Chat list ViewModel
- Settings ViewModel
- Premium upgrade ViewModel
- Referral dashboard ViewModel
- Safety center ViewModel

---

## CRITICAL USER FLOWS & IMPLEMENTATIONS

### 1. SIGNUP FLOW
**Location**: `/home/user/TeamUp/TeamUp/SignUpView.swift` → `/home/user/TeamUp/TeamUp/AuthService.swift`

**Implementation:**
- Email/password validation with regex
- Input sanitization (InputSanitizer.swift)
- Firebase Auth user creation
- Firestore user document creation
- Referral code validation (ReferralManager.swift)

**Test Files:**
- `/home/user/TeamUp/TeamUpTests/AuthServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/EndToEndFlowTests.swift`

### 2. MATCH FLOW (Like/Swipe)
**Location**: `/home/user/TeamUp/TeamUp/DiscoverView.swift` → `/home/user/TeamUp/TeamUp/SwipeService.swift` → `/home/user/TeamUp/TeamUp/MatchService.swift`

**Implementation:**
- User discovery with filters (DiscoverViewModel.loadUsers)
- Like/Pass/SuperLike actions (SwipeService)
- Mutual match detection
- Match creation (MatchService.createMatch)
- Daily like limits enforcement

**Test Files:**
- `/home/user/TeamUp/TeamUpTests/SwipeServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/MatchServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/DiscoverViewModelTests.swift`

### 3. MESSAGE FLOW
**Location**: `/home/user/TeamUp/TeamUp/ChatView.swift` → `/home/user/TeamUp/TeamUp/MessageService.swift`

**Implementation:**
- Real-time message loading with pagination
- Content moderation (InputSanitizer + ContentModerator)
- Message sending and updates
- Read status tracking
- Push notifications on new messages

**Test Files:**
- `/home/user/TeamUp/TeamUpTests/MessageServiceTests.swift`
- `/home/user/TeamUp/TeamUpTests/ChatViewModelTests.swift`
- `/home/user/TeamUp/TeamUpTests/MessagePaginationTests.swift`

### 4. PREMIUM UPGRADE FLOW
**Location**: `/home/user/TeamUp/TeamUp/PremiumUpgradeView.swift` → `/home/user/TeamUp/TeamUp/StoreManager.swift`

**Implementation:**
- StoreKit 2 in-app purchase integration
- Receipt validation (BackendAPIService)
- Premium feature unlocks
- Subscription management

**Test Files:**
- `/home/user/TeamUp/TeamUpTests/StoreManagerTests.swift`
- ⚠️ E2E upgrade flow not fully covered

### 5. REFERRAL FLOW
**Location**: `/home/user/TeamUp/TeamUp/SignUpView.swift` → `/home/user/TeamUp/TeamUp/ReferralManager.swift`

**Implementation:**
- Referral code validation
- Bonus distribution (referrer + new user)
- Tracking in Firestore
- Notification on successful referral

**Test Files:**
- `/home/user/TeamUp/TeamUpTests/ReferralManagerTests.swift`
- ⚠️ E2E referral signup flow not fully covered

---

## MOCK IMPLEMENTATIONS READY FOR USE

### Available Mocks in MockServices.swift

```swift
// 10+ Production-Ready Mocks:
MockAuthService          // signIn, createUser, signOut, fetchUser
MockUserService          // fetchUser, fetchUsers, with call tracking
MockMatchService         // fetchMatches, createMatch, hasMatched
MockMessageService       // sendMessage, fetchMessages, markAsRead
MockSwipeService         // likeUser, passUser, hasSwipedOn
MockNetworkManager       // isConnected, performRequest with failure config
MockContentModerator     // isAppropriate, containsProfanity, filterProfanity
MockImageUploadService   // uploadProfileImage, uploadChatImage
MockNotificationService  // requestPermission, sendNotification
MockInterestService      // sendInterest, fetchInterest, hasLiked
MockHapticManager        // notification, impact, selection
MockAnalyticsService     // trackEvent, setUserProperty
MockLogger               // info, warning, error, debug with tracking
```

### Key Mock Features
- **Call Tracking**: Every mock tracks method calls (`sendMessageCalled`, `fetchUsersCalled`, etc.)
- **Configurable Behavior**: `shouldFail`, `shouldCreateMatch`, `isConnectedValue`
- **Return Values**: `mockUser`, `mockInterest`, `users[]` - all configurable
- **MainActor Safe**: UI-related mocks use @MainActor

---

## DEPENDENCY INJECTION: Current vs. Recommended

### Current Approach (Singletons)
```swift
class DiscoverViewModel: ObservableObject {
    // Tightly coupled - hard to test
    let userService = UserService.shared
    let swipeService = SwipeService.shared
}
```

### Recommended Approach (Dependency Injection)
```swift
class DiscoverViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let swipeService: SwipeServiceProtocol
    
    init(
        userService: UserServiceProtocol = UserService.shared,
        swipeService: SwipeServiceProtocol = SwipeService.shared
    ) {
        self.userService = userService
        self.swipeService = swipeService
    }
}

// In tests:
let mockService = MockUserService()
let viewModel = DiscoverViewModel(userService: mockService)
```

### Repository Protocols Already Defined
Located in: `/home/user/TeamUp/TeamUp/RepositoryProtocols.swift`
- UserRepository
- MatchRepository
- MessageRepository
- InterestRepository

These protocols define the contract but aren't yet implemented by actual services.

---

## TEST HELPERS & UTILITIES

### TestFixtures.swift - Data Builders
Location: `/home/user/TeamUp/TeamUpTests/TestFixtures.swift`

**User Fixtures:**
```swift
TestFixtures.createTestUser()           // Full customizable user
TestFixtures.createPremiumUser()        // Pre-configured premium user
TestFixtures.createVerifiedUser()       // Verified user
TestFixtures.createBatchUsers(count:)   // Generate multiple test users
```

**Match Fixtures:**
```swift
TestFixtures.createTestMatch()          // Single match
TestFixtures.createBatchMatches()       // Multiple matches
```

**Message Fixtures:**
```swift
TestFixtures.createTestMessage()        // Single message
TestFixtures.createConversation()       // Full conversation with N messages
```

**Test Utilities:**
```swift
TestFixtures.waitFor(condition:)        // Async condition polling
TestFixtures.waitForChange(expectedValue:) // Wait for property change
String.randomEmail()                    // Generate random test email
String.randomName()                     // Generate random test name
Date.daysAgo(_:), Date.hoursAgo(_:)     // Time helpers
```

### IntegrationTestBase.swift - Firebase Emulator Support
Location: `/home/user/TeamUp/TeamUpTests/IntegrationTestBase.swift`

**Features:**
- Firebase Emulator configuration (Auth, Firestore, Storage)
- Test data creation: `createTestUser()`, `createTestMatch()`, `createTestMessage()`
- Automatic cleanup of test data
- Network simulation: `simulateNetworkDelay()`
- Performance measurement: `measureTime()`, `measureMemory()`
- Condition waiting with timeout: `waitForCondition()`

**Usage:**
```swift
@MainActor
func testSomething() async throws {
    let testBase = try await IntegrationTestBase()
    defer { Task { await testBase.cleanup() } }
    
    let user = try await testBase.createTestUser()
    // Test logic...
}
```

---

## ABSOLUTE FILE PATHS FOR KEY FILES

### Source Code
- **AuthService**: `/home/user/TeamUp/TeamUp/AuthService.swift`
- **UserService**: `/home/user/TeamUp/TeamUp/UserService.swift`
- **MatchService**: `/home/user/TeamUp/TeamUp/MatchService.swift`
- **MessageService**: `/home/user/TeamUp/TeamUp/MessageService.swift`
- **SwipeService**: `/home/user/TeamUp/TeamUp/SwipeService.swift`
- **DiscoverViewModel**: `/home/user/TeamUp/TeamUp/DiscoverViewModel.swift`
- **ChatViewModel**: `/home/user/TeamUp/TeamUp/ChatViewModel.swift`
- **RepositoryProtocols**: `/home/user/TeamUp/TeamUp/RepositoryProtocols.swift`

### Test Code
- **Test Directory**: `/home/user/TeamUp/TeamUpTests/`
- **MockServices**: `/home/user/TeamUp/TeamUpTests/MockServices.swift`
- **TestFixtures**: `/home/user/TeamUp/TeamUpTests/TestFixtures.swift`
- **IntegrationTestBase**: `/home/user/TeamUp/TeamUpTests/IntegrationTestBase.swift`
- **End-to-End Tests**: `/home/user/TeamUp/TeamUpTests/EndToEndFlowTests.swift`

### Documentation
- **Testing Guide**: `/home/user/TeamUp/TESTING_GUIDE.md`

---

## QUICK TEST CHECKLIST

Use this to identify which services need additional testing:

### Authentication & Users
- [ ] AuthService - ✅ Covered
- [ ] UserService - ✅ Covered
- [ ] BiometricAuthManager - ⚠️ Partial
- [ ] VerificationService - ⚠️ Needs testing

### Matching & Discovery
- [ ] MatchService - ✅ Covered
- [ ] SwipeService - ✅ Covered
- [ ] DiscoverViewModel - ✅ Covered
- [ ] InterestService - ⚠️ Partial (mock exists)

### Messaging
- [ ] MessageService - ✅ Covered
- [ ] ChatViewModel - ✅ Covered
- [ ] Message pagination - ✅ Covered
- [ ] Content moderation - ✅ Covered

### Premium & Payments
- [ ] StoreManager - ✅ Covered
- [ ] Premium upgrade E2E - ⚠️ Needs E2E test
- [ ] Subscription management - ⚠️ Partial

### Safety & Content
- [ ] InputSanitizer - ✅ Covered
- [ ] ContentModerator - ✅ Covered
- [ ] SafetyManager - ⚠️ Minimal
- [ ] ReportingManager - ⚠️ Minimal

### Infrastructure
- [ ] NetworkManager - ✅ Mock exists
- [ ] CircuitBreaker - ⚠️ Minimal
- [ ] OfflineManager - ⚠️ Limited E2E
- [ ] QueryCache - ⚠️ Minimal

---

## NEXT STEPS RECOMMENDATION

1. **High Priority**: Refactor ViewModels to accept service protocols as init parameters
2. **High Priority**: Implement repository patterns for data access layer
3. **Medium Priority**: Add comprehensive E2E tests for premium and referral flows
4. **Medium Priority**: Add offline operation E2E tests
5. **Low Priority**: Add UI/snapshot tests for critical screens

