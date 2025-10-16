package com.project424.flink;

public class TelemetryRecord {
    public String vehicleId;
    public String sessionId;
    public double timestamp;
    public int channelId;
    public String channelName;
    public double channelValue;
    public String channelUnit;
    public String channelMinValue;
    public String channelMaxValue;
    public double channelMultiplier;
    public String channelGroup;
    public int channelCount;
    public String expectedFrequency;
    public double actualFrequency;
    public int updateInterval;
    public String frequencyLabel;
    public String semantic;

    // Empty constructor required by Flink
    public TelemetryRecord() {}

    // Full constructor for convenience
    public TelemetryRecord(String vehicleId, String sessionId, double timestamp, int channelId,
                           String channelName, double channelValue, String channelUnit,
                           String channelMinValue, String channelMaxValue, double channelMultiplier,
                           String channelGroup, int channelCount, String expectedFrequency,
                           double actualFrequency, int updateInterval, String frequencyLabel,
                           String semantic) {
        this.vehicleId = vehicleId;
        this.sessionId = sessionId;
        this.timestamp = timestamp;
        this.channelId = channelId;
        this.channelName = channelName;
        this.channelValue = channelValue;
        this.channelUnit = channelUnit;
        this.channelMinValue = channelMinValue;
        this.channelMaxValue = channelMaxValue;
        this.channelMultiplier = channelMultiplier;
        this.channelGroup = channelGroup;
        this.channelCount = channelCount;
        this.expectedFrequency = expectedFrequency;
        this.actualFrequency = actualFrequency;
        this.updateInterval = updateInterval;
        this.frequencyLabel = frequencyLabel;
        this.semantic = semantic;
    }

    @Override
    public String toString() {
        return vehicleId + "," + sessionId + "," + timestamp + "," + channelId + "," + channelValue;
    }
}
