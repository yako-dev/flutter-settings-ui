class InvalidDevicePlatformDeviceUsage implements Exception {
  final String message;
  final String usageSrc;

  InvalidDevicePlatformDeviceUsage(this.usageSrc)
      : message = "You can't use the DevicePlatform.device in this context. "
            "Incorrect platform: $usageSrc";

  @override
  String toString() => message;
}
