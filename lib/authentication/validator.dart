class Validator {
  static String? validateName({required String name}) {
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z]+$');
    if (name.isEmpty) {
      return 'Required field';
    }
    else if (!nameRegExp.hasMatch(name)) {
      return 'English letters only';
    }
    else if (name.length > 13) {
      return 'Name is too long';
    }
    return null;
  }

  static String? validateEmail({required String email}) {
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$");

    if (email.isEmpty) {
      return 'Required field';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }
    else if (email.length > 45) {
      return 'Email is too long';
    }

    return null;
  }

  static String? validatePassword({required String password}) {
    if (password.isEmpty) {
      return 'Required field';
    } else if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }
    else if (password.length > 40) {
      return 'Password is too long';
    }
    return null;
  }

  static String? validatePhoneNumber({required String phoneNumber}) {
    if (phoneNumber.isEmpty) {
      return 'Required field'; //field is not required
    } else if (phoneNumber.length != 10) {
      return 'Invalid phone number length';
    }
    return null;
  }

  static String? validateLicenseNumber({required String licenseNumber}) {
    if (licenseNumber.isEmpty) {
      return 'Required field';
    } else if (licenseNumber.length != 8 && licenseNumber.length != 7) {
      return 'Invalid license number length';
    } else if (licenseNumber[0] == '0') {
      return 'Invalid license number';
    }
    return null;
  }

  static String? validateBirthDate({required String birthDate}) {
    if(birthDate.isEmpty) {
      return 'Required field';
    }
    return null;
  }

  static String? validateCreditCardNumber({required String creditCardNumber}) {
    final RegExp cardNumberRegExp = RegExp(r'^[0-9]{4}(?: [0-9]{4}){3}$');
    if (creditCardNumber.isEmpty) {
      return 'Required field';
    } else if (creditCardNumber.length != 19) {
      return 'Invalid credit card number';
    } else if(!cardNumberRegExp.hasMatch(creditCardNumber)){
      return 'Invalid credit card number';
    }
    return null;
  }

  static String? validateCreditCardGoodThru({required String goodThru}) {
    final RegExp goodThruRegExp = RegExp(r'^(0[1-9]|1[0-2])\/(2[2-9]|3[0-9])$');
    final RegExp expiredRegExp = RegExp(r'^(0[1-9]|1[0-2])\/(1[0-9]|0[0-9]|2[0-1])$');
    if (goodThru.isEmpty) {
      return 'Required field';
    } else if (goodThru.length != 5) {
      return 'Invalid length';
    } else if (expiredRegExp.hasMatch(goodThru)) {
      return 'expired date';
    } else if (!goodThruRegExp.hasMatch(goodThru)) {
      return 'bad format';
    }

    return null;
  }

  static String? validateCVV({required String cvv}) {
    if (cvv.isEmpty) {
      return 'Required field';
    } else if (cvv.length != 3) {
      return 'Invalid CVV';
    }
    return null;
  }
}