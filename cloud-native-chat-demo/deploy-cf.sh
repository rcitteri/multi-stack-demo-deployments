#!/bin/bash
set -e

echo "======================================"
echo "Deploying Cloud Native Chat to Cloud Foundry"
echo "======================================"
echo ""

APP_NAME="cloud-native-chat"
INITIALIZER_NAME="cloud-native-chat-initializer"
APP_JAR="target/cloud-native-chat-demo-1.0.0.jar"
INITIALIZER_JAR="target/cloud-native-chat-initializer-1.0.0.jar"

# Step 1: Build both applications
echo "Step 1: Building applications..."
echo "Building main application..."
mvn clean package -DskipTests
if [ ! -f "$APP_JAR" ]; then
    echo "Error: Main app JAR not found after build"
    exit 1
fi
echo "✓ Main app JAR built: $APP_JAR"

echo "Building database initializer..."
cd initializer
mvn clean package -DskipTests
cd ..
if [ ! -f "initializer/target/cloud-native-chat-initializer-1.0.0.jar" ]; then
    echo "Error: Initializer JAR not found after build"
    exit 1
fi
# Copy initializer JAR to main target directory for CF push
cp initializer/target/cloud-native-chat-initializer-1.0.0.jar target/
echo "✓ Initializer JAR built: $INITIALIZER_JAR"
echo ""

# Step 2: Create services
echo "Step 2: Creating Cloud Foundry services..."
./create-services.sh
echo ""

# Step 3: Push database initializer (no-route)
echo "Step 3: Pushing database initializer (no-route)..."
cf push "$INITIALIZER_NAME" -f manifest-initializer.yml
echo "✓ Initializer application pushed"
echo ""

# Step 4: Run database initializer task (12-Factor: Admin Process)
echo "Step 4: Running database initializer task..."
echo "This demonstrates Factor XII: Admin/management tasks as one-off processes"
echo ""

echo "Task command: java -jar app.jar"
echo ""

# cf run-task cloud-native-chat --command 'JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.17.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -Djava.ext.dirs=  -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" && CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=27736 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.:$PWD/.java-buildpack/container_security_provider/container_security_provider-1.20.0_RELEASE.jar org.springframework.boot.loader.launch.JarLauncher --spring.profiles.active=initializer' --name initialize-db

TASK_OUTPUT=$(cf run-task "$INITIALIZER_NAME" --command 'JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.17.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -Djava.ext.dirs=  -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" && CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=27736 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.:$PWD/.java-buildpack/container_security_provider/container_security_provider-1.20.0_RELEASE.jar org.springframework.boot.loader.launch.JarLauncher' --name initialize-db')'
TASK_ID=$(echo "$TASK_OUTPUT" | grep "task id:" | awk '{print $3}')

echo "✓ Database initializer task started with ID: $TASK_ID"
echo "Waiting for task to complete..."

# Wait for task to complete
MAX_WAIT=120  # 2 minutes
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    TASK_STATE=$(cf tasks "$INITIALIZER_NAME" | grep "^$TASK_ID" | awk '{print $3}')

    if [ "$TASK_STATE" = "SUCCEEDED" ]; then
        echo "✓ Database initializer task completed successfully"
        echo ""
        echo "Task logs:"
        cf logs "$INITIALIZER_NAME" --recent | grep "db-initializer" || true
        echo ""
        break
    elif [ "$TASK_STATE" = "FAILED" ]; then
        echo "✗ Database initializer task failed"
        echo ""
        echo "Task logs:"
        cf logs "$INITIALIZER_NAME" --recent | grep "db-initializer" || true
        echo ""
        exit 1
    fi

    echo "  Task state: $TASK_STATE - waiting... (${ELAPSED}s elapsed)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "✗ Task did not complete within $MAX_WAIT seconds"
    exit 1
fi

# Step 5: Push main application
echo "Step 5: Pushing main application..."
cf push "$APP_NAME" -f manifest.yml
echo "✓ Main application pushed and started"
echo ""

# Step 6: Show application info
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""
cf app "$APP_NAME"
echo ""
echo "Application URL:"
cf app "$APP_NAME" | grep "routes:" | awk '{print "  https://" $2}'
echo ""
echo "To view logs:"
echo "  cf logs $APP_NAME --recent"
echo ""
echo "To view tasks:"
echo "  cf tasks $APP_NAME"
