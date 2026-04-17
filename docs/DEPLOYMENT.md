# Deployment Guide

## Production Deployment

### Prerequisites
- HarmonyOS 4.0+ device or emulator
- DevEco Studio 4.0+
- Signing certificate configured

### Build Process

1. **Clean Build**
   ```bash
   cd harmony-tvbox-client
   ./gradlew clean assembleRelease
   ```

2. **Generate Signed Package**
   - Open project in DevEco Studio
   - Select Build > Generate Signed Bundle/APK
   - Configure signing credentials
   - Generate release package

3. **Install to Device**
   ```bash
   hdc install entry/build/outputs/hap/entry-release-signed.hap
   ```

### Configuration Options

#### Runtime Modes
- **Local Mode**: Load from `tvbox.json` in assets
- **API Mode**: Connect to remote API server
- **Mock Mode**: Use simulated data

#### Environment Variables
```bash
export TVBOX_API_URL="https://api.example.com/v1"
export TVBOX_CONFIG_URL="https://config.example.com/tvbox.json"
export TVBOX_LOG_LEVEL="INFO"
```

### Performance Tuning

#### Memory Optimization
- Enable ARC (Automatic Reference Counting)
- Use lazy loading for large datasets
- Implement proper cleanup in lifecycle methods

#### Startup Optimization
- Preload critical resources
- Defer non-essential initialization
- Use splash screen for better UX

### Monitoring

#### Key Metrics
- App startup time
- Page transition duration
- API response times
- Memory usage patterns
- Crash reporting

#### Health Checks
- API endpoint availability
- Configuration validity
- Storage accessibility
- Network connectivity

## Troubleshooting

### Common Issues

**Build Failures**
- Check Node.js version compatibility
- Verify SDK path configuration
- Clean and rebuild project

**Runtime Errors**
- Check device compatibility
- Verify permissions configuration
- Review crash logs in DevEco Studio

**Performance Issues**
- Profile memory usage
- Analyze network requests
- Check for memory leaks

### Support

- GitHub Issues: https://github.com/suyizhang/harmony-tvbox-client/issues
- Email: support@tvbox.app
- Documentation: https://docs.tvbox.app