W, H = 1500, 790

GROUPS = [
    dict(style='azure', x=230, y=20, w=1010, h=750, label='Azure · Brazil South'),
    dict(style='vnet', x=255, y=65, w=960, h=685, label='VNet · NSG libera 22/8000/8080/9000 só p/ IP do dev (+ webhooks GitHub)'),
    dict(style='soft', x=275, y=110, w=920, h=620, label='VM Ubuntu 24.04 · Standard_B2ms'),
    dict(style='compose', x=295, y=150, w=880, h=330, label='infra/ · Jenkins (JCasC) + SonarQube'),
    dict(style='compose', x=295, y=505, w=880, h=205, label='queimadas · deploy', label_right=True),
    dict(style='plain', x=1270, y=65, w=200, h=200, label='IaC'),
]

NODES = [
    dict(icon='User', x=100, y=80, label=['Dev', 'commit']),
    dict(icon='github', x=100, y=255, label=['GitHub', 'repo + webhook']),
    dict(icon='github', x=100, y=455, label=['GHCR', 'queimadas-api:<sha>']),
    dict(icon='Users', x=100, y=630, label=['Usuário', 'HTTP :8000']),
    dict(icon='jenkins', x=400, y=255, bg='#FFFFFF', label=['Jenkins', 'Jenkinsfile']),
    dict(icon='python', x=560, y=375, size=50, label=['1 · pytest', 'testes + cobertura']),
    dict(icon='sonarqubeserver', x=740, y=375, size=50, label=['2 · SonarQube', 'Quality Gate']),
    dict(icon='docker', x=920, y=375, size=50, label=['3 · docker build', 'Chainguard / Wolfi']),
    dict(icon='trivy', x=1090, y=375, size=50, label=['4 · Trivy', 'bloqueia CRITICAL']),
    dict(icon='fastapi', x=740, y=630, label=['Queimadas API', 'FastAPI :8000']),
    dict(icon='terraform', x=1370, y=160, label=['Terraform', 'provisiona a VM']),
]

EDGES = [
    dict(points=[(100, 150), (100, 223)], label='git push', label_at=(100, 185)),
    dict(points=[(132, 255), (368, 255)], label='webhook', label_at=(250, 255)),
    # barramento das etapas
    dict(points=[(428, 255), (1090, 255), (1090, 346)]),
    dict(points=[(560, 255), (560, 346)]),
    dict(points=[(740, 255), (740, 346)]),
    dict(points=[(920, 255), (920, 346)]),
    # 5 · push
    dict(points=[(372, 278), (190, 278), (190, 455), (132, 455)], label='5 · docker push', label_at=(190, 370)),
    # 6 · deploy + validação
    dict(points=[(400, 325), (400, 560), (740, 560), (740, 598)], label='6 · compose up + curl /health', label_at=(560, 560)),
    dict(points=[(132, 630), (708, 630)], label='GET /queimadas', label_at=(500, 630)),
    dict(points=[(1338, 160), (1199, 160)]),
]
