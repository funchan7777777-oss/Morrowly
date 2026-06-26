enum LegalDocumentMarker { userAgreement, privacyPolicy }

extension LegalDocumentMarkerCopy on LegalDocumentMarker {
  String get title {
    return switch (this) {
      LegalDocumentMarker.userAgreement => 'User Agreement',
      LegalDocumentMarker.privacyPolicy => 'Privacy Policy',
    };
  }

  Uri get uri {
    return switch (this) {
      LegalDocumentMarker.userAgreement => Uri.parse(
        'https://sites.google.com/view/morrowly-termsofservice/home',
      ),
      LegalDocumentMarker.privacyPolicy => Uri.parse(
        'https://sites.google.com/view/morrowly-privacypolicy/home',
      ),
    };
  }
}
