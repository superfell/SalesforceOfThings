package controllers;

import play.*;
import play.mvc.*;

import java.util.*;

import models.*;

import com.sforce.ws.*;
import com.sforce.soap.partner.*;
import com.sforce.soap.partner.sobject.*;

public class Application extends Controller {

    public static void index() {
        render();
    }

	public static void sensor(String sid, String val) throws ConnectionException {
		System.out.println("POST sid=" + sid + " val=" + val);
		Salesforce salesforce = new Salesforce();
		salesforce.addSensorReading(sid, val);
	}
	
	static class Salesforce {

		Salesforce() {
			// Update conf/sfdc.conf with the username & password values
			this((String)Play.configuration.get("sfdc.username"), (String)Play.configuration.get("sfdc.password"));
		}
		Salesforce(String un, String pwd) {
			this.username = un;
			this.password = pwd;
		}
		
		private final String username, password;
		private PartnerConnection conn;
		
		void addSensorReading(String sensorId, String sensorValue) throws ConnectionException {
			SObject r = new SObject();
			r.setType("Sensor_Reading__c");
			r.setField("SensorValue__c", sensorValue);
			SObject s = new SObject();
			s.setType("Sensor__c");
			s.setField("ArduinoId__c", sensorId);
			r.setField("Sensor__r", s);
			
			SaveResult sr = getConnection().create(new SObject [] {r})[0];
			System.out.println(sr.isSuccess() ? sr.getId() : sr.getErrors()[0].getMessage());
		}
		
		PartnerConnection getConnection() throws ConnectionException {
			if (conn == null) {
				ConnectorConfig cfg = new ConnectorConfig();
				cfg.setUsername(username);
				cfg.setPassword(password);
				conn = Connector.newConnection(cfg);
				
			}
			return conn;
		}
	}
}