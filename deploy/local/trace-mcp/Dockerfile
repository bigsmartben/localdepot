FROM node:22-bookworm-slim
ARG TRACE_MCP_VERSION=3.31.3
RUN npm install -g "trace-mcp@${TRACE_MCP_VERSION}" \
  && trace --version
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh
ENV TRACE_PROJECT_ROOT=/workspaces/project \
    TRACE_HOME=/workspaces/project/.cache/trace-home \
    TRACE_MCP_TELEMETRY=off \
    NODE_ENV=production
EXPOSE 3741
ENTRYPOINT ["sh", "/entrypoint.sh"]
