#!/bin/bash
set -e

echo "======================================"
echo "Running Database Initializer Task"
echo "======================================"
echo ""

INITIALIZER_NAME="cloud-native-chat-initializer"

# Check if initializer app exists
if ! cf app "$INITIALIZER_NAME" > /dev/null 2>&1; then
    echo "Error: Initializer application '$INITIALIZER_NAME' not found"
    echo "Please deploy the application first using ./deploy-cf.sh"
    echo ""
    echo "Or manually push the initializer:"
    echo "  cd initializer && mvn clean package -DskipTests && cd .."
    echo "  cp initializer/target/cloud-native-chat-initializer-1.0.0.jar target/"
    echo "  cf push $INITIALIZER_NAME -f manifest-initializer.yml"
    exit 1
fi

# Run the database initializer task
echo "Running task: java -jar app.jar"
echo ""

TASK_OUTPUT=$(cf run-task "$INITIALIZER_NAME" --command 'JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.17.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -Djava.ext.dirs=  -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" && CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=27736 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.:$PWD/.java-buildpack/container_security_provider/container_security_provider-1.20.0_RELEASE.jar org.springframework.boot.loader.launch.JarLauncher')
TASK_ID=$(echo "$TASK_OUTPUT" | grep "task id:" | awk '{print $3}')

echo "✓ Task started with ID: $TASK_ID"
echo ""
echo "To monitor task status:"
echo "  cf tasks $INITIALIZER_NAME"
echo ""
echo "To view task logs:"
echo "  cf logs $INITIALIZER_NAME --recent | grep db-initializer"
echo ""
echo "Monitoring task progress..."

# Monitor task completion
while true; do
    TASK_STATE=$(cf tasks "$INITIALIZER_NAME" | grep "^$TASK_ID" | awk '{print $3}')

    if [ "$TASK_STATE" = "SUCCEEDED" ]; then
        echo "✓ Database initializer task completed successfully"
        echo ""
        echo "Task logs:"
        cf logs "$INITIALIZER_NAME" --recent | grep -A 20 "db-initializer" || true
        break
    elif [ "$TASK_STATE" = "FAILED" ]; then
        echo "✗ Database initializer task failed"
        echo ""
        echo "Task logs:"
        cf logs "$INITIALIZER_NAME" --recent | grep -A 20 "db-initializer" || true
        exit 1
    fi

    echo "  Task state: $TASK_STATE - waiting..."
    sleep 3
done

echo ""
echo "======================================"
echo "Task completed successfully"
echo "======================================"
