# 🏠 Homelab Self-Hosting Stack

Stack completa de serviços self-hosted para uso pessoal ou comercial (PMEs).  
Roda sem domínio, acessível por IP local na rede.

---

## 📦 Serviços incluídos

| Serviço        | Substitui         | Porta  | Descrição                        |
|----------------|-------------------|--------|----------------------------------|
| **n8n**        | Zapier / Make     | `:5678`| Automação de processos           |
| **Outline**    | Notion            | `:3000`| Wiki e base de conhecimento      |
| **Listmonk**   | Mailchimp         | `:9000`| E-mail marketing                 |
| **Uptime Kuma**| StatusPage        | `:3001`| Monitoramento de disponibilidade |
| **MinIO**      | AWS S3            | `:9001`| Storage de arquivos (console)    |
| PostgreSQL     | —                 | interno| Banco de dados (Listmonk+Outline)|
| Redis          | —                 | interno| Cache (Outline)                  |
| Backup         | —                 | —      | Backup diário automático         |

---

## 📁 Estrutura do projeto

```
selfhosting/
├── docker-compose.yml
├── .env.example
├── .env                  ← criado por você (não versionar)
├── init-db.sh            ← cria os bancos no PostgreSQL
├── backups/              ← gerado automaticamente
└── README.md
```

---

## 🚀 Deploy passo a passo

### 1. Instalar Docker

```bash
curl -fsSL https://get.docker.com | sh
```

### 2. Copiar os arquivos do projeto

```bash
mkdir -p ~/selfhosting && cd ~/selfhosting
# copie docker-compose.yml, .env.example e init-db.sh para esta pasta
```

### 3. Configurar variáveis de ambiente

```bash
cp .env.example .env
nano .env
```

> ⚠️ Se a sua PG_PASSWORD contiver caracteres especiais como @, #, /, :
> eles precisam ser URL-encoded no DATABASE_URL do Outline.
>
> Exemplos: @ → %40 | # → %23 | ! → %21 | / → %2F | : → %3A
>
> Dica: use senhas apenas com letras, números, - e _ para evitar esse problema.

### 4. Permissão ao script de banco

```bash
chmod +x init-db.sh
```

### 5. Gerar as chaves do Outline

```bash
openssl rand -hex 32  # cole em OUTLINE_SECRET_KEY
openssl rand -hex 32  # cole em OUTLINE_UTILS_SECRET
```

### 6. Subir a stack

```bash
docker compose up -d
```

### 7. Inicializar o Listmonk (somente na primeira vez)

```bash
docker compose run --rm listmonk ./listmonk --install
```

---

## 🌐 Acessar os serviços

Substitua IP pelo IP fixo do seu servidor (ex: 192.168.1.100):

| Serviço       | URL                  | Credenciais               |
|---------------|----------------------|---------------------------|
| n8n           | http://IP:5678       | definido no .env           |
| Outline       | http://IP:3000       | criado no primeiro acesso  |
| Listmonk      | http://IP:9000       | criado no --install        |
| Uptime Kuma   | http://IP:3001       | criado no primeiro acesso  |
| MinIO console | http://IP:9001       | definido no .env           |

---

## 🔧 Problemas conhecidos e soluções

### n8n — erro de cookie ao fazer login via HTTP
Causa: n8n exige HTTPS por padrão para cookies seguros
Solução: N8N_SECURE_COOKIE=false já aplicado no compose


### Outline — The operation was unable to achieve a quorum (Redlock)
Causa: bug no latest do Outline com Redis single-node
Solução: versão fixada em outlinewiki/outline:0.76.1 + RATE_LIMITER_ENABLED=false

### Outline — The server does not support SSL connections
Causa: Outline tenta conectar ao PostgreSQL via SSL por padrão
Solução: PGSSLMODE=disable já aplicado no compose

### minio-setup — container reiniciando em loop
Causa: sem restart: "no", Docker reinicia o container indefinidamente
Solução: restart: "no" já aplicado. Status correto é: Exited (0)

---

## 🗄️ Backup

Backups automáticos rodam todo dia às 03:00 e ficam em ./backups/
Retenção: 14 dias.

Para backup offsite (S3 / Cloudflare R2), adicione no serviço backup:

  AWS_S3_BUCKET_NAME: seu-bucket
  AWS_ACCESS_KEY_ID: sua_key
  AWS_SECRET_ACCESS_KEY: seu_secret
  AWS_ENDPOINT: https://seu-endpoint

---

## 🔄 Manutenção

```bash
# Atualizar todas as imagens
docker compose pull && docker compose up -d

# Ver uso de recursos
docker stats

# Logs de um serviço
docker logs outline -f
docker logs n8n -f

# Parar a stack
docker compose down

# Parar e remover volumes (APAGA DADOS)
docker compose down -v
```

---

## 📈 Próximos passos (uso comercial)

1. Comprar domínio (Registro.br ~R$40/ano) e adicionar Traefik + TLS
2. Configurar SMTP no Listmonk e Outline
3. Configurar alertas no Uptime Kuma (Telegram, e-mail)
4. Migrar para VPS (Hetzner ~€4–10/mês) com 3+ clientes
5. Adicionar autenticação centralizada com Authelia ou Authentik

---

## 💰 Modelo de negócio sugerido

| Plano       | Preço/mês | Inclui                                    |
|-------------|-----------|-------------------------------------------|
| Starter     | R$ 197    | 1 app, backups, monitoramento             |
| Business    | R$ 397    | Até 3 apps, n8n, dashboard, SLA           |
| Premium     | R$ 797    | Stack completa, integrações, suporte prio |

---

Gerado com Claude — stack testada em Homelab com Portainer + Docker Compose
