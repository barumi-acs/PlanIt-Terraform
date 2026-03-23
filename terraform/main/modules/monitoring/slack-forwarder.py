import json
import os
import urllib.request
import urllib.error


def lambda_handler(event, context):
    """
    SNS 이벤트를 받아서 Slack으로 전송하는 Lambda 함수 (하이브리드 방식)
    - Critical 알림: alert-critical + 해당 서비스 Topic 모두로 전송
    - Warning/Info 알림: 해당 서비스 Topic으로만 전송
    """
    
    # 환경 변수에서 Slack Webhook URL 가져오기
    SLACK_WEBHOOKS = {
        'critical': os.environ.get('SLACK_WEBHOOK_CRITICAL'),
        'user': os.environ.get('SLACK_WEBHOOK_USER'),
        'schedule': os.environ.get('SLACK_WEBHOOK_SCHEDULE'),
        'strategy': os.environ.get('SLACK_WEBHOOK_STRATEGY'),
        'insight': os.environ.get('SLACK_WEBHOOK_INSIGHT'),
        'insightai': os.environ.get('SLACK_WEBHOOK_INSIGHTAI')
    }
    
    try:
        # SNS 메시지 파싱
        sns_message = event['Records'][0]['Sns']['Message']
        sns_topic_arn = event['Records'][0]['Sns']['TopicArn']
        
        # Topic ARN에서 채널 타입 추출 (alert-critical, alert-user, alert-schedule 등)
        topic_name = sns_topic_arn.split(':')[-1]  # 예: PI-DEV-alert-critical
        channel_type = topic_name.split('-')[-1]  # 예: critical, user, schedule
        
        # Grafana 알림 메시지는 JSON 형식
        try:
            alert_data = json.loads(sns_message)
        except json.JSONDecodeError:
            # JSON이 아닌 경우 텍스트로 처리
            alert_data = {'message': sns_message}
        
        # Severity 및 Service 추출
        severity = alert_data.get('labels', {}).get('severity', 'info')
        service = alert_data.get('labels', {}).get('service', channel_type)
        
        # Webhook URL 선택 (Topic 기반)
        webhook_url = SLACK_WEBHOOKS.get(channel_type)
        
        if not webhook_url:
            print(f"Webhook URL not found for channel: {channel_type}")
            return {
                'statusCode': 400,
                'body': json.dumps(f'Webhook URL not configured for {channel_type}')
            }
        
        # Slack 메시지 포맷팅
        slack_message = format_slack_message(alert_data, severity, service, channel_type)
        
        # Slack으로 전송
        send_to_slack(webhook_url, slack_message)
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Alert sent to Slack ({channel_type}) successfully')
        }
        
    except Exception as e:
        print(f"Error processing alert: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }


def format_slack_message(alert_data, severity, service, channel_type):
    """
    Grafana 알림을 Slack 메시지 형식으로 변환 (하이브리드 방식)
    """
    
    # Severity에 따른 색상 및 이모지
    severity_config = {
        'critical': {'color': '#FF0000', 'emoji': ':rotating_light:'},
        'warning': {'color': '#FFA500', 'emoji': ':warning:'},
        'info': {'color': '#0000FF', 'emoji': ':information_source:'}
    }
    
    # 서비스별 이모지
    service_emoji = {
        'user': ':bust_in_silhouette:',
        'schedule': ':calendar:',
        'strategy': ':dart:',
        'insight': ':bar_chart:',
        'insightai': ':robot_face:'
    }
    
    config = severity_config.get(severity, severity_config['info'])
    svc_emoji = service_emoji.get(service, ':gear:')
    
    # 기본 메시지 구조
    if isinstance(alert_data, dict) and 'annotations' in alert_data:
        # Grafana 알림 형식
        title = alert_data.get('annotations', {}).get('summary', 'Alert')
        description = alert_data.get('annotations', {}).get('description', '')
        alert_name = alert_data.get('labels', {}).get('alertname', 'Unknown')
        
        message = {
            'text': f"{config['emoji']} {svc_emoji} *[{severity.upper()}] [{service.upper()}]* {title}",
            'attachments': [
                {
                    'color': config['color'],
                    'fields': [
                        {
                            'title': 'Alert Name',
                            'value': alert_name,
                            'short': True
                        },
                        {
                            'title': 'Severity',
                            'value': severity.upper(),
                            'short': True
                        },
                        {
                            'title': 'Service',
                            'value': service.upper(),
                            'short': True
                        },
                        {
                            'title': 'Channel',
                            'value': channel_type.upper(),
                            'short': True
                        }
                    ]
                }
            ]
        }
        
        if description:
            message['attachments'][0]['fields'].append({
                'title': 'Description',
                'value': description,
                'short': False
            })
            
    else:
        # 단순 텍스트 메시지
        message = {
            'text': f"{config['emoji']} {svc_emoji} *[{severity.upper()}] [{service.upper()}]* {alert_data.get('message', str(alert_data))}"
        }
    
    return message


def send_to_slack(webhook_url, message):
    """
    Slack Webhook으로 메시지 전송
    """
    
    payload = json.dumps(message).encode('utf-8')
    
    req = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={'Content-Type': 'application/json'}
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            if response.status != 200:
                raise Exception(f"Slack API returned status {response.status}")
            print("Message sent to Slack successfully")
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code} - {e.reason}")
        raise
    except urllib.error.URLError as e:
        print(f"URL Error: {e.reason}")
        raise
