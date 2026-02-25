
const String host = "https://loyalty-be-production.up.railway.app";
// const String host = "http://10.0.2.2:5000"; // Android emulator
const String baseUrl = "$host/api";

// Business Endpoints
class BusinessEndpoints {
  static const String base = "$baseUrl/businesses";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Customer Endpoints
class CustomerEndpoints {
  static const String base = "$baseUrl/customers";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byPhone(String phone) => "$base/phone/$phone";
  static String signup() => "$base/signup";
  static String login() => "$base/login";
  static String googleSignIn() => "$base/google-signin";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Business Customer Endpoints
class BusinessCustomerEndpoints {
  static const String base = "$baseUrl/business-customers";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String byCustomer(String customerId) => "$base/customer/$customerId";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Loyalty Program Endpoints
class LoyaltyProgramEndpoints {
  static const String base = "$baseUrl/loyalty-programs";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String activeByBusiness(String businessId) => "$base/business/$businessId/active";
  static String incompleteByCustomer(String customerId) => "$base/customer/$customerId/incomplete";
  static String collectedByCustomer(String customerId) => "$base/customer/$customerId/collected";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Customer Loyalty Card Endpoints
class CustomerLoyaltyCardEndpoints {
  static const String base = "$baseUrl/customer-loyalty-cards";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byCustomer(String customerId) => "$base/customer/$customerId";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String byBusinessCustomer(String businessCustomerId) => "$base/business-customer/$businessCustomerId";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Business Location Endpoints
class BusinessLocationEndpoints {
  static const String base = "$baseUrl/business-locations";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Business User Endpoints (uses /api/employees in backend)
class BusinessUserEndpoints {
  static const String base = "$baseUrl/employees";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byEmail(String email) => "$base/email/$email";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String byLocation(String locationId) => "$base/location/$locationId";
  static String login() => "$base/login";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Stamp Transaction Endpoints
class StampTransactionEndpoints {
  static const String base = "$baseUrl/stamp-transactions";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byCustomer(String customerId) => "$base/customer/$customerId";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String byCard(String cardId) => "$base/card/$cardId";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Reward Redemption Endpoints
class RewardRedemptionEndpoints {
  static const String base = "$baseUrl/reward-redemptions";
  static String all() => base;
  static String byId(String id) => "$base/$id";
  static String byCustomer(String customerId) => "$base/customer/$customerId";
  static String byBusiness(String businessId) => "$base/business/$businessId";
  static String byCard(String cardId) => "$base/card/$cardId";
  static String create() => base;
  static String update(String id) => "$base/$id";
  static String delete(String id) => "$base/$id";
}

// Health Check Endpoint
class HealthEndpoints {
  static const String check = "$baseUrl/health";
}